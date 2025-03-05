use starknet::ContractAddress;
use snforge_std::{declare, ContractClassTrait, DeclareResultTrait};


// Import the interface for the EscrowFactory
use escrownet_contract::escrow::escrow_factory::IEscrowFactoryDispatcherTrait;
use escrownet_contract::escrow::escrow_factory::IEscrowFactoryDispatcher;
// Relevants imports for the Escrow contract
use escrownet_contract::interface::iescrow::IEscrowDispatcherTrait;
use escrownet_contract::interface::iescrow::IEscrowDispatcher;

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

// Helper function to deploy the EscrowFactory contract
fn deploy_escrow_factory() -> IEscrowFactoryDispatcher {
    let contract = declare("EscrowFactory");
    let (contract_address, _err) = contract.unwrap().contract_class().deploy(@array![]).unwrap();
    IEscrowFactoryDispatcher { contract_address }
}

// Helper function to deploy the Escrow contract
fn deploy_escrow() -> ContractAddress {
    // deploy  Esrownet
    let escrow_class_hash = declare("EscrowContract").unwrap().contract_class();

    let mut escrow_constructor_calldata: Array<felt252> = array![];

    let benefeciary = BENEFICIARY();
    let depositor = DEPOSITOR();
    let arbiter = ARBITER();

    benefeciary.serialize(ref escrow_constructor_calldata);
    depositor.serialize(ref escrow_constructor_calldata);
    arbiter.serialize(ref escrow_constructor_calldata);

    let (escrow_contract_address, _) = escrow_class_hash
        .deploy(@escrow_constructor_calldata)
        .unwrap();

    return (escrow_contract_address);
}

fn declare_escrow() -> ClassHash {
    let contract = declare("EscrowContract");
    contract.unwrap().class_hash()
}

#[test]
fn test_deploy_escrow() {
    let factory_dispatcher = deploy_escrow_factory();

    // Define addresses for beneficiary, depositor, and arbiter
    let beneficiary = BENEFICIARY();
    let depositor = DEPOSITOR();
    let arbiter = ARBITER();
    let salt: felt252 = SALT();

    // Deploy an escrow contract
    let escrow_address = factory_dispatcher.deploy_escrow(beneficiary, depositor, arbiter, salt);

    // Get all escrow contracts
    let escrow_contracts = factory_dispatcher.get_escrow_contracts();

    // Assert that the deployed contract's address is in the list of escrow contracts
    assert(escrow_contracts.len() == 1, 'Incorrect number of escrow contracts');
    assert(escrow_contracts[0] == escrow_address, 'Incorrect escrow contract address');
}

#[test]
fn test_deploy_multiple_escrows() {
    let factory_dispatcher = deploy_escrow_factory();
    let escrow_class_hash = declare_escrow(); // Get the real class hash

    // Define addresses for beneficiary, depositor, and arbiter
    let beneficiary = BENEFICIARY();
    let depositor = DEPOSITOR();
    let arbiter = ARBITER();
    let salt: felt252 = SALT();

    // Deploy two escrow contracts
    let escrow_address1 = factory_dispatcher.deploy_escrow(beneficiary, depositor, arbiter, salt);
    let escrow_address2 = factory_dispatcher
        .deploy_escrow(beneficiary, depositor, arbiter, salt + 1_u8.into());

    // Get all escrow contracts
    let escrow_contracts = factory_dispatcher.get_escrow_contracts();

    // Assert that both deployed contract addresses are in the list of escrow contracts
    assert(escrow_contracts.len() == 2, 'Incorrect number of escrow contracts');
    assert(
        escrow_contracts[0] == escrow_address1, 'Incorrect escrow contract address for contract 1'
    );
    assert(
        escrow_contracts[1] == escrow_address2, 'Incorrect escrow contract address for contract 2'
    );
}

#[test]
fn test_get_escrow_contracts_empty() {
    let factory_dispatcher = deploy_escrow_factory();

    // Get all escrow contracts when no contracts have been deployed
    let escrow_contracts = factory_dispatcher.get_escrow_contracts();

    // Assert that the returned array is empty
    assert(escrow_contracts.len() == 0, 'Escrow contracts should be empty');
}
