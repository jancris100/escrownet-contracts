#[cfg(test)]
mod tests {
    use starknet::ContractAddress;
    use snforge_std::{
        declare, ContractClassTrait, start_cheat_caller_address_global, start_cheat_caller_address,
        stop_cheat_caller_address, cheat_caller_address, CheatSpan, spy_events,
        EventSpyAssertionsTrait
    };
    use escrownet_contract::escrow::escrow_factory::IEscrowFactory;

    use core::convert::TryFrom;

    fn FACTORY_OWNER() -> ContractAddress {
        ContractAddress::try_from(0x123456_felt252).unwrap()
    }

    fn BENEFICIARY() -> ContractAddress {
        ContractAddress::try_from(0xabcdef_felt252).unwrap()
    }

    fn DEPOSITOR() -> ContractAddress {
        ContractAddress::try_from(0x987654_felt252).unwrap()
    }

    fn ARBITER() -> ContractAddress {
        ContractAddress::try_from(0x555555_felt252).unwrap()
    }

    fn deploy_escrow_factory() -> ContractAddress {
        let contract = declare("EscrowFactory").unwrap();
        let class_hash = contract.class_hash();

        let constructor_calldata: Array<felt252> = array![];
        let (contract_address, _) = starknet::syscalls::deploy_syscall(
            class_hash, 0, constructor_calldata.span(), false
        )
            .unwrap();

        contract_address
    }
    #[test]
    fn test_deploy_escrow() {
        let escrow_factory_address = deploy_escrow_factory();

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
        let escrow_factory_address = deploy_escrow_factory();

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
