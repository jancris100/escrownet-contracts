#[cfg(test)]
mod tests {
    use starknet::ContractAddress;
    use snforge_std::{
        declare, ContractClassTrait, start_cheat_caller_address, stop_cheat_caller_address,
        spy_events, EventSpyAssertionsTrait,
    };
    use escrownet_contract::interface::iescrowfactory::IEscrowFactoryDispatcher;

    fn FACTORY_OWNER() -> ContractAddress {
        'factory_owner'.try_into().unwrap()
    }

    fn BENEFICIARY() -> ContractAddress {
        'beneficiary'.try_into().unwrap()
    }

    fn DEPOSITOR() -> ContractAddress {
        'depositor'.try_into().unwrap()
    }

    fn ARBITER() -> ContractAddress {
        'arbiter'.try_into().unwrap()
    }

    // 📌 Función de configuración: despliega el contrato EscrowFactory
    fn __setup__() -> ContractAddress {
        let factory_class_hash = declare("EscrowFactory").unwrap().contract_class();

        let constructor_calldata: Array<felt252> = array![];

        let (factory_contract_address, _) = factory_class_hash
            .deploy(@constructor_calldata)
            .unwrap();

        factory_contract_address
    }

    #[test]
    fn test_setup() {
        let contract_address = __setup__();
        println!("EscrowFactory deployed at: {:?}", contract_address);
    }

    #[test]
    fn test_deploy_escrow() {
        // 📌 1. Desplegar EscrowFactory
        let factory_address = __setup__();
        let factory_dispatcher = IEscrowFactoryDispatcher { contract_address: factory_address };

        // 📌 2. Simular que el factory owner está llamando la función
        let factory_owner = FACTORY_OWNER();
        start_cheat_caller_address(factory_address, factory_owner);

        let beneficiary = BENEFICIARY();
        let depositor = DEPOSITOR();
        let arbiter = ARBITER();
        let salt: felt252 = 12345_felt252;

        let mut spy = spy_events(); // Capturar eventos

        // 📌 3. Llamar a `deploy_escrow`
        let escrow_address = factory_dispatcher.deploy_escrow(beneficiary, depositor, arbiter, salt);

        // 📌 4. Verificar que se ha desplegado correctamente
        assert(escrow_address != ContractAddress::default(), "Escrow address cannot be zero");

        // 📌 5. Verificar que el evento `EscrowDeployed` fue emitido
        spy.assert_event("EscrowDeployed", (escrow_address, beneficiary, depositor, arbiter));

        // 📌 6. Detener la simulación del usuario
        stop_cheat_caller_address(factory_address);
    }

    #[test]
    fn test_get_escrow_contracts() {
        // 📌 1. Desplegar EscrowFactory
        let factory_address = __setup__();
        let factory_dispatcher = IEscrowFactoryDispatcher { contract_address: factory_address };

        let factory_owner = FACTORY_OWNER();
        start_cheat_caller_address(factory_address, factory_owner);

        let beneficiary = BENEFICIARY();
        let depositor = DEPOSITOR();
        let arbiter = ARBITER();
        let salt1: felt252 = 12345_felt252;
        let salt2: felt252 = 67890_felt252;

        // 📌 2. Desplegar dos contratos Escrow
        factory_dispatcher.deploy_escrow(beneficiary, depositor, arbiter, salt1);
        factory_dispatcher.deploy_escrow(beneficiary, depositor, arbiter, salt2);

        // 📌 3. Obtener la lista de contratos
        let escrow_contracts = factory_dispatcher.get_escrow_contracts();

        // 📌 4. Verificar que los contratos han sido registrados correctamente
        assert(escrow_contracts.len() == 2, "Should be 2 Escrow contracts");

        stop_cheat_caller_address(factory_address);
    }
}
