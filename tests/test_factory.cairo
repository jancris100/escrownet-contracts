#[cfg(test)]
mod tests {
    use starknet::ContractAddress;
    use snforge_std::{
        declare, start_cheat_caller_address, stop_cheat_caller_address, spy_events,
        DeclareResultTrait,ContractClassTrait,
    };
    use escrownet_contract::escrow::escrow_factory::IEscrowFactory;

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

    // Setup corregido usando serialize y deploy con @
    fn __setup__() -> ContractAddress {
        let escrow_class = declare("EscrowFactory").unwrap().contract_class();

        let mut constructor_calldata: Array<felt252> = array![];
        let factory_owner = FACTORY_OWNER();
        factory_owner.serialize(ref constructor_calldata);
        100_u128.serialize(ref constructor_calldata);

        let (contract_address, _) = escrow_class.deploy(@constructor_calldata).unwrap();
        return (contract_address);
    }
    #[test]
    #[available_gas(3000000)]
    fn test_deploy_escrow() {
        let factory_address = __setup__();
        let salt: felt252 = 12345_felt252;

        // Mockeamos el caller como factory owner
        start_cheat_caller_address(FACTORY_OWNER());

        let dispatcher = IEscrowFactory { contract_address: factory_address };

        // Deploy nuevo Escrow
        let escrow_address = dispatcher.deploy_escrow(BENEFICIARY(), DEPOSITOR(), ARBITER(), salt);

        // Verificación básica
        assert(escrow_address != ContractAddress::default(), "Invalid escrow address");

        // Verificación de evento
        let mut spy = spy_events(factory_address);
        spy
            .assert_emitted(
                spy
                    .event("EscrowDeployed")
                    .with_data(
                        array![
                            escrow_address.into(),
                            BENEFICIARY().into(),
                            DEPOSITOR().into(),
                            ARBITER().into()
                        ]
                    )
            );

        stop_cheat_caller_address();
    }
    #[test]
    #[available_gas(5000000)]
    fn test_get_escrow_contracts() {
        let factory_address = __setup__();

        start_cheat_caller_address(FACTORY_OWNER());
        let dispatcher = IEscrowFactory { contract_address: factory_address };

        // Primer deploy
        let escrow1 = dispatcher.deploy_escrow(BENEFICIARY(), DEPOSITOR(), ARBITER(), 111_felt252);

        // Segundo deploy
        let escrow2 = dispatcher.deploy_escrow(BENEFICIARY(), DEPOSITOR(), ARBITER(), 222_felt252);

        // Verificar almacenamiento
        let deployed_contracts = dispatcher.get_escrow_contracts();
        assert(deployed_contracts.len() == 2, "Should have 2 contracts");
        assert(deployed_contracts[0] == escrow1, "Mismatch first contract");
        assert(deployed_contracts[1] == escrow2, "Mismatch second contract");

        stop_cheat_caller_address();
    }
}
