use starknet::ContractAddress;
use snforge_std::{declare, ContractClassTrait, DeclareResultTrait};

// Import the interface for the EscrowFactory (now for the TestContract)
use escrownet_contract::escrow::escrow_factory::IEscrowFactoryDispatcherTrait;
use escrownet_contract::escrow::escrow_factory::IEscrowFactoryDispatcher;

// Constants for addresses
fn BENEFICIARY() -> ContractAddress {
    starknet::contract_address_const::<'beneficiary'>()
}

fn DEPOSITOR() -> ContractAddress {
    starknet::contract_address_const::<'depositor'>()
}

fn ARBITER() -> ContractAddress {
    starknet::contract_address_const::<'arbiter'>()
}

fn SALT() -> felt252 {
    12345_u32.into()
}

// Helper function to declare the Escrow contract
fn declare_escrow() -> ClassHash {
    let contract = declare("EscrowContract");
    contract.unwrap().class_hash()
}
// Helper function to deploy the TestContractWithFactory contract
fn deploy_test_contract() -> IEscrowFactoryDispatcher {
    let contract = declare("TestContractWithFactory");
    let (contract_address, _err) = contract.unwrap().contract_class().deploy(@array![]).unwrap();
    IEscrowFactoryDispatcher { contract_address }
}

#[test]
fn test_deploy_escrow() {
    let test_contract_dispatcher = deploy_test_contract();
    let escrow_class_hash = declare_escrow();

    // Define addresses for beneficiary, depositor, and arbiter
    let beneficiary = BENEFICIARY();
    let depositor = DEPOSITOR();
    let arbiter = ARBITER();
    let salt: felt252 = SALT();

    // Deploy an escrow contract THROUGH the TestContract
    let escrow_address = test_contract_dispatcher
        .deploy_escrow(beneficiary, depositor, arbiter, salt);

    // Get all escrow contracts THROUGH the TestContract
    let escrow_contracts = test_contract_dispatcher.get_escrow_contracts();

    // Assert that the deployed contract's address is in the list of escrow contracts
    assert(escrow_contracts.len() == 1, "Incorrect number of escrow contracts");
    assert(escrow_contracts[0] == escrow_address, "Incorrect escrow contract address");
}

#[test]
fn test_deploy_multiple_escrows() {
    let test_contract_dispatcher = deploy_test_contract();
    let escrow_class_hash = declare_escrow();

    // Define addresses for beneficiary, depositor, and arbiter
    let beneficiary = BENEFICIARY();
    let depositor = DEPOSITOR();
    let arbiter = ARBITER();
    let salt: felt252 = SALT();

    // Deploy two escrow contracts THROUGH the TestContract
    let escrow_address1 = test_contract_dispatcher
        .deploy_escrow(beneficiary, depositor, arbiter, salt);
    let escrow_address2 = test_contract_dispatcher
        .deploy_escrow(beneficiary, depositor, arbiter, salt + 1_u8.into());

    // Get all escrow contracts THROUGH the TestContract
    let escrow_contracts = test_contract_dispatcher.get_escrow_contracts();

    // Assert that both deployed contract addresses are in the list of escrow contracts
    assert(escrow_contracts.len() == 2, "Incorrect contracts");
    assert(escrow_contracts[0] == escrow_address1, "Incorrect 1");
    assert(escrow_contracts[1] == escrow_address2, "Incorrect 2");
}

#[test]
fn test_get_escrow_contracts_empty() {
    let test_contract_dispatcher = deploy_test_contract();

    // Get all escrow contracts when no contracts have been deployed
    let escrow_contracts = test_contract_dispatcher.get_escrow_contracts();

    // Assert that the returned array is empty
    assert(escrow_contracts.len() == 0, "Escrow contracts should be empty");
}
