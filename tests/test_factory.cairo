#[cfg(test)]
mod tests {
    use starknet::ContractAddress;
    use snforge_std::{
        declare, deploy, call_contract, start_cheat_caller_address, stop_cheat_caller_address,
        spy_events
    };
    use escrownet_contract::escrow::escrow_factory::IEscrowFactory;

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

    fn deploy_escrow_factory() -> ContractAddress {
        let contract = declare("EscrowFactory").unwrap();
        let class_hash = contract.class_hash();

        let constructor_calldata: Array<felt252> = array![];
        let contract_address = deploy(class_hash, constructor_calldata, false).unwrap();

        contract_address
    }

    #[test]
    fn test_deploy_escrow() {
        let escrow_factory_address = deploy_escrow_factory();

        let beneficiary = BENEFICIARY();
        let depositor = DEPOSITOR();
        let arbiter = ARBITER();
        let salt: felt252 = 10_felt252;

        let escrow_address: ContractAddress = call_contract(
            escrow_factory_address, "deploy_escrow", (beneficiary, depositor, arbiter, salt)
        )
            .unwrap();

        assert(escrow_address != ContractAddress::default(), "Escrow address should not be zero");
    }

    #[test]
    fn test_get_escrow_contracts() {
        let escrow_factory_address = deploy_escrow_factory();

        let beneficiary = BENEFICIARY();
        let depositor = DEPOSITOR();
        let arbiter = ARBITER();
        let salt1: felt252 = 10_felt252;
        let salt2: felt252 = 11_felt252;

        let escrow_address1: ContractAddress = call_contract(
            escrow_factory_address, "deploy_escrow", (beneficiary, depositor, arbiter, salt1)
        )
            .unwrap();

        let escrow_address2: ContractAddress = call_contract(
            escrow_factory_address, "deploy_escrow", (beneficiary, depositor, arbiter, salt2)
        )
            .unwrap();

        let escrow_contracts: Array<ContractAddress> = call_contract(
            escrow_factory_address, "get_escrow_contracts", ()
        )
            .unwrap();

        assert(escrow_contracts.len() == 2, "Incorrect number of escrow contracts");
        assert(escrow_contracts[0] == escrow_address1, "Incorrect escrow address at index 0");
        assert(escrow_contracts[1] == escrow_address2, "Incorrect escrow address at index 1");
    }
}
