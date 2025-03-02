#[cfg(test)]
mod tests {
    use starknet::{ContractAddress};
    use snforge_std::{
        declare, spy_events, DeclareResultTrait, ContractClassTrait,
        start_cheat_caller_address_global, stop_cheat_caller_address_global, EventSpyAssertionsTrait
    };
    use escrownet_contract::escrow::escrow_factory::EscrowFactory;
    use escrownet_contract::escrow::escrow_factory::IEscrowFactoryDispatcher;
    use escrownet_contract::escrow::escrow_factory::IEscrowFactoryDispatcherTrait;
    use escrownet_contract::escrow::errors::Errors;

    fn BENEFICIARY() -> ContractAddress {
        'beneficiary'.try_into().unwrap()
    }

    fn DEPOSITOR() -> ContractAddress {
        'depositor'.try_into().unwrap()
    }

    fn ARBITER() -> ContractAddress {
        'arbiter'.try_into().unwrap()
    }

    fn FACTORY_OWNER() -> ContractAddress {
        'factory_owner'.try_into().unwrap()
    }

    fn INITIAL_CONTRACT() -> ContractAddress {
        0_felt252.try_into().unwrap()
    }
    // Setup corregido usando serialize y deploy con @
    fn __setup__() -> ContractAddress {
        // Declarar el contrato Escrow
        let escrow_declaration = declare("Escrow").unwrap();
        let escrow_contract_class = escrow_declaration.contract_class();

        // Declarar EscrowFactory
        let escrow_factory_declaration = declare("EscrowFactory").unwrap();
        let escrow_factory_class = escrow_factory_declaration.contract_class();

        // ✅ Desplegar EscrowFactory pasando el hash de Escrow
        let (contract_address, _) = escrow_factory_class
            .deploy(@array![escrow_contract_class])
            .unwrap();

        return (contract_address);
    }


    #[test]
    #[available_gas(3000000)]
    fn test_deploy_escrow() {
        let (contract_address) = __setup__();
        let mut spy = spy_events();
        let mut salt: felt252 = 12345_felt252;
        start_cheat_caller_address_global(FACTORY_OWNER());
        let dispatcher = IEscrowFactoryDispatcher { contract_address };

        let escrow_address = dispatcher.deploy_escrow(BENEFICIARY(), DEPOSITOR(), ARBITER(), salt);
        assert(escrow_address == INITIAL_CONTRACT(), Errors::INVALID_AMOUNT);

        spy
            .assert_emitted(
                @array![
                    (
                        contract_address,
                        EscrowFactory::Event::EscrowDeployed(
                            EscrowFactory::EscrowDeployed {
                                beneficiary: BENEFICIARY(),
                                depositor: DEPOSITOR(),
                                arbiter: ARBITER(),
                                escrow_address: escrow_address,
                                salt: salt,
                            }
                        )
                    )
                ]
            );

        stop_cheat_caller_address_global();
    }

    #[test]
    #[available_gas(5000000)]
    fn test_get_escrow_contracts() {
        let (contract_address) = __setup__();
        start_cheat_caller_address_global(FACTORY_OWNER());
        let dispatcher = IEscrowFactoryDispatcher { contract_address };

        // Primer deploy
        let escrow1 = dispatcher.deploy_escrow(BENEFICIARY(), DEPOSITOR(), ARBITER(), 111_felt252);
        // Segundo deploy
        let escrow2 = dispatcher.deploy_escrow(BENEFICIARY(), DEPOSITOR(), ARBITER(), 222_felt252);
        // Verificar almacenamiento
        let deployed_contracts = dispatcher.get_escrow_contracts();
        assert(deployed_contracts.len() == 2, Errors::INVALID_AMOUNT_OF_ADDRESSES);
        assert(*deployed_contracts[0] == escrow1, 'Mismatch first contract');
        assert(*deployed_contracts[1] == escrow2, 'Mismatch second contract');

        stop_cheat_caller_address_global();
    }
}
