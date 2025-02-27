#[cfg(test)]
mod tests {
    use starknet::ContractAddress;
    use snforge_std::{
        declare, deploy, start_cheat_caller_address, stop_cheat_caller_address, call_contract
    };
    use escrownet_contract::escrow::escrow_factory::IEscrowFactory;

    // 📌 Direcciones de prueba corregidas
    fn FACTORY_OWNER() -> ContractAddress {
        ContractAddress::from(0x123456_felt252)
    }

    fn BENEFICIARY() -> ContractAddress {
        ContractAddress::from(0xabcdef_felt252)
    }

    fn DEPOSITOR() -> ContractAddress {
        ContractAddress::from(0x987654_felt252)
    }

    fn ARBITER() -> ContractAddress {
        ContractAddress::from(0x555555_felt252)
    }

    // 📌 Función de configuración corregida
    fn __setup__() -> ContractAddress {
        let factory_class_hash = declare("EscrowFactory").unwrap().class_hash;
        let constructor_calldata: Array<felt252> = array![];
        let factory_contract_address = deploy(factory_class_hash, constructor_calldata, false).unwrap();
        factory_contract_address
    }

    #[test]
    fn test_deploy_escrow() {
        let factory_address = __setup__();

        let factory_owner = FACTORY_OWNER();
        start_cheat_caller_address(factory_address, factory_owner);

        let beneficiary = BENEFICIARY();
        let depositor = DEPOSITOR();
        let arbiter = ARBITER();
        let salt: felt252 = 12345_felt252;

        let escrow_address: ContractAddress = call_contract(
            factory_address, "deploy_escrow", (beneficiary, depositor, arbiter, salt)
        ).unwrap();

        assert(escrow_address != ContractAddress::default(), "Escrow address cannot be zero");

        stop_cheat_caller_address(factory_address);
    }

    #[test]
    fn test_get_escrow_contracts() {
        let factory_address = __setup__();

        let factory_owner = FACTORY_OWNER();
        start_cheat_caller_address(factory_address, factory_owner);

        let beneficiary = BENEFICIARY();
        let depositor = DEPOSITOR();
        let arbiter = ARBITER();
        let salt1: felt252 = 12345_felt252;
        let salt2: felt252 = 67890_felt252;

        call_contract(factory_address, "deploy_escrow", (beneficiary, depositor, arbiter, salt1)).unwrap();
        call_contract(factory_address, "deploy_escrow", (beneficiary, depositor, arbiter, salt2)).unwrap();

        let escrow_contracts: Array<ContractAddress> = call_contract(factory_address, "get_escrow_contracts", ()).unwrap();

        assert(escrow_contracts.len() == 2, "Should be 2 Escrow contracts");

        stop_cheat_caller_address(factory_address);
    }
}
