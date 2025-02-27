#[cfg(test)]
mod tests {
    use starknet::ContractAddress;
    use snforge_std::{
        declare, ContractClassTrait, start_cheat_caller_address, stop_cheat_caller_address,
        spy_events, get_class_hash
    };
    use escrownet_contract::escrow::escrow_factory::IEscrowFactory;

    // Constantes mejoradas usando felt252! macro
    const FACTORY_OWNER: ContractAddress = 12345.try_into().unwrap();
    const BENEFICIARY: ContractAddress = 67890.try_into().unwrap();
    const DEPOSITOR: ContractAddress = 54321.try_into().unwrap();
    const ARBITER: ContractAddress = 98765.try_into().unwrap();

    fn setup() -> ContractAddress {
        let contract = declare("EscrowFactory").unwrap();
        let class_hash = get_class_hash("EscrowFactory");

        let mut constructor_calldata = array![
            FACTORY_OWNER.into(), // Conversión directa a felt252
            100_u128.into() // Usar u128 para el fee
        ];

        let (contract_address, _) = contract.deploy(constructor_calldata.span()).unwrap();

        contract_address
    }

    #[test]
    #[available_gas(1000000)]
    fn test_deploy_escrow() {
        let escrow_factory = setup();
        let salt: felt252 = 10_felt252;

        // Mockeamos el caller
        start_cheat_caller_address(FACTORY_OWNER);
        let dispatcher = IEscrowFactory { contract_address: escrow_factory };

        let escrow_address = dispatcher.deploy_escrow(BENEFICIARY, DEPOSITOR, ARBITER, salt);

        // Verificación básica
        assert(escrow_address != ContractAddress::default(), "Invalid escrow address");

        // Verificación de evento
        let mut spy = spy_events(escrow_factory);
        spy
            .assert_emitted(
                spy
                    .event("EscrowDeployed")
                    .with_data(
                        array![
                            escrow_address.into(),
                            BENEFICIARY.into(),
                            DEPOSITOR.into(),
                            ARBITER.into()
                        ]
                    )
            );

        stop_cheat_caller_address();
    }

    #[test]
    #[available_gas(2000000)] // Más gas para múltiples operaciones
    fn test_get_escrow_contracts() {
        let escrow_factory = setup();

        start_cheat_caller_address(FACTORY_OWNER);
        let dispatcher = IEscrowFactory { contract_address: escrow_factory };

        // Despliegues múltiples
        let escrow1 = dispatcher.deploy_escrow(BENEFICIARY, DEPOSITOR, ARBITER, 10);
        let escrow2 = dispatcher.deploy_escrow(BENEFICIARY, DEPOSITOR, ARBITER, 20);

        // Verificación de almacenamiento
        let contracts = dispatcher.get_escrow_contracts();
        assert(contracts.len() == 2, "Should have 2 contracts");
        assert(contracts.at(0) == escrow1, "First contract mismatch");
        assert(contracts.at(1) == escrow2, "Second contract mismatch");

        stop_cheat_caller_address();
    }
}
