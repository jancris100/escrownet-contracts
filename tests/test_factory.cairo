#[cfg(test)]
mod tests {
    use starknet::ContractAddress;
    use snforge_std::{
        declare, deploy_contract, start_cheat_caller_address, stop_cheat_caller_address,
    };
    use escrownet_contract::interface::iescrow::IEscrowFactoryDispatcher;

    // 📌 Direcciones de prueba
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
        let factory_class_hash = declare("EscrowFactory").unwrap().class_hash();

        let constructor_calldata: Array<felt252> = array![];

        let (factory_contract_address, _) = deploy_contract(
            factory_class_hash, constructor_calldata, false
        )
            .unwrap();

        factory_contract_address
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

        // 📌 3. Llamar a `deploy_escrow`
        let escrow_address = factory_dispatcher
            .deploy_escrow(beneficiary, depositor, arbiter, salt);

        // 📌 4. Verificar que se ha desplegado correctamente
        assert(escrow_address != ContractAddress::default(), "Escrow address cannot be zero");

        // 📌 5. Detener la simulación del usuario
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
