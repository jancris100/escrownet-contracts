#[cfg(test)]
mod tests {
    use super::*;
    use starknet::ContractAddress;
    use snforge_std::{ declare, ContractClassTrait, DeclareResultTrait, start_cheat_caller_address, stop_cheat_caller_address, spy_events };
    use escrownet_contract::interface::iescrow::IEscrowDispatcher;

    // Helper function to deploy the EscrowFactory contract
    fn deploy_escrow_factory() -> ContractAddress {
        let contract = declare("EscrowFactory");
        let (contract_address, _err) = contract
            .unwrap()
            .contract_class()
            .deploy(@array![])
            .unwrap();

        contract_address
    }

    // Test for deploying an escrow contract
    #[test]
    fn test_deploy_escrow() {
        // Deploy the EscrowFactory
        let escrow_factory_address = deploy_escrow_factory();

        // Prepare test addresses
        let beneficiary: ContractAddress = 123_u128.try_into().unwrap();
        let depositor: ContractAddress = 456_u128.try_into().unwrap();
        let arbiter: ContractAddress = 789_u128.try_into().unwrap();
        let salt: felt252 = 10_felt252;

        // Get the dispatcher
        let dispatcher = IEscrowFactoryDispatcher { contract_address: escrow_factory_address };

        // Deploy an escrow contract
        let escrow_address = dispatcher
            .deploy_escrow(beneficiary, depositor, arbiter, salt);

        // Assert that the escrow address is not zero
        assert(escrow_address != ContractAddress::default(), 'Escrow address should not be zero');
    }

    #[test]
    fn test_get_escrow_contracts() {
        // Deploy the EscrowFactory
        let escrow_factory_address = deploy_escrow_factory();

        // Prepare test addresses
        let beneficiary: ContractAddress = 123_u128.try_into().unwrap();
        let depositor: ContractAddress = 456_u128.try_into().unwrap();
        let arbiter: ContractAddress = 789_u128.try_into().unwrap();
        let salt: felt252 = 10_felt252;

          // Get the dispatcher
        let dispatcher = IEscrowFactoryDispatcher { contract_address: escrow_factory_address };

        // Deploy two escrow contracts
        let escrow_address1 = dispatcher
            .deploy_escrow(beneficiary, depositor, arbiter, salt);
        let escrow_address2 = dispatcher
            .deploy_escrow(beneficiary, depositor, arbiter, salt + 1_felt252);

        // Retrieve the escrow contract addresses
        let escrow_contracts = dispatcher.get_escrow_contracts();

        // Assert that the length of the array is 2
        assert(escrow_contracts.len() == 2, 'Incorrect number of escrow contracts');

        // Assert that the addresses are correct
        assert(escrow_contracts<a href="undefined" target="_blank" className="bg-light-secondary dark:bg-dark-secondary px-1 rounded ml-1 no-underline text-xs text-black/70 dark:text-white/70 relative">0</a> == escrow_address1, 'Incorrect escrow address at index 0');
        assert(escrow_contracts<a href="https://foundry-rs.github.io/starknet-foundry/testing/testing.html#writing-tests" target="_blank" className="bg-light-secondary dark:bg-dark-secondary px-1 rounded ml-1 no-underline text-xs text-black/70 dark:text-white/70 relative">1</a> == escrow_address2, 'Incorrect escrow address at index 1');
    }
}