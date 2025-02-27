#[cfg(test)]
mod tests {
    use starknet::ContractAddress;
    use snforge_std::{declare, start_cheat_caller_address_global, stop_cheat_caller_address};
    use escrownet_contract::escrow::escrow_factory::IEscrowFactory;

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

    fn __setup__() -> ContractAddress {
        let contract = declare("EscrowFactory").unwrap();
        let class_hash = contract.class_hash();
    
        let mut constructor_calldata: Array<felt252> = array![];
    
        // Serialize constructor arguments
        let initial_owner: ContractAddress = FACTORY_OWNER();
        let fee: u32 = 100;
    
        constructor_calldata.append(initial_owner.into()); // Convert ContractAddress to felt252
        constructor_calldata.append(fee.into()); // Convert u32 to felt252
    
        let (contract_address, _) = contract.deploy(@constructor_calldata).unwrap();
    
        contract_address
    }
    #[test]
    fn test_deploy_escrow() {
        let escrow_factory_address = __setup__();

        let beneficiary = BENEFICIARY();
        let depositor = DEPOSITOR();
        let arbiter = ARBITER();
        let salt: felt252 = 10_felt252;

        start_cheat_caller_address_global(FACTORY_OWNER());

        let dispatcher = IEscrowFactory { contract_address: escrow_factory_address };

        let escrow_address = dispatcher.deploy_escrow(beneficiary, depositor, arbiter, salt);

        assert(escrow_address != ContractAddress::default(), "Escrow address should not be zero");

        stop_cheat_caller_address();
    }
    #[test]
    fn test_get_escrow_contracts() {
        let escrow_factory_address = __setup__();

        let beneficiary = BENEFICIARY();
        let depositor = DEPOSITOR();
        let arbiter = ARBITER();
        let salt1: felt252 = 10_felt252;
        let salt2: felt252 = 11_felt252;

        start_cheat_caller_address_global(FACTORY_OWNER());

        let dispatcher = IEscrowFactory { contract_address: escrow_factory_address };

        let escrow_address1 = dispatcher.deploy_escrow(beneficiary, depositor, arbiter, salt1);
        let escrow_address2 = dispatcher.deploy_escrow(beneficiary, depositor, arbiter, salt2);

        let escrow_contracts = dispatcher.get_escrow_contracts();

        assert(escrow_contracts.len() == 2, "Incorrect number of escrow contracts");
        assert(escrow_contracts[0] == escrow_address1, "Incorrect escrow address at index 0");
        assert(escrow_contracts[1] == escrow_address2, "Incorrect escrow address at index 1");

        stop_cheat_caller_address();
    }
}
