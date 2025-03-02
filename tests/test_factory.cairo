use starknet::ContractAddress;
use snforge_std::{
    declare, ContractClassTrait, DeclareResultTrait, start_cheat_caller_address,
    stop_cheat_caller_address, spy_events, EventSpyAssertionsTrait
};
use escrownet_contract::EscrowFactory::IEscrowFactoryDispatcher;

fn BENEFICIARY() -> ContractAddress {
    'beneficiary'.try_into().unwrap()
}

fn DEPOSITOR() -> ContractAddress {
    'depositor'.try_into().unwrap()
}

fn ARBITER() -> ContractAddress {
    'arbiter'.try_into().unwrap()
}

// *************************************************************************
//                              SETUP
// *************************************************************************
fn __setup__() -> ContractAddress {
    let factory_class_hash = declare("EscrowFactory").unwrap().contract_class();
    let constructor_calldata: Array<felt252> = array![];
    let (factory_contract_address, _) = factory_class_hash.deploy(constructor_calldata).unwrap();

    return factory_contract_address;
}

// *************************************************************************
//                          TEST: deploy_escrow
// *************************************************************************
#[test]
fn test_deploy_escrow() {
    let factory_address = __setup__();
    let factory_dispatcher = IEscrowFactoryDispatcher { contract_address: factory_address };

    let mut spy = spy_events();

    let beneficiary = BENEFICIARY();
    let depositor = DEPOSITOR();
    let arbiter = ARBITER();
    let salt: felt252 = 12345;

    start_cheat_caller_address(factory_address, depositor);

    let escrow_address = factory_dispatcher.deploy_escrow(beneficiary, depositor, arbiter, salt);

    stop_cheat_caller_address(factory_address);

    assert!(escrow_address != ContractAddress::from_felt(0x0), "Escrow address is invalid.");

    spy.assert_event_emitted(escrow_address, "EscrowInitialized");
}

// *************************************************************************
//                      TEST: get_escrow_contracts
// *************************************************************************
#[test]
fn test_get_escrow_contracts() {
    let factory_address = __setup__();
    let factory_dispatcher = IEscrowFactoryDispatcher { contract_address: factory_address };

    let beneficiary = BENEFICIARY();
    let depositor = DEPOSITOR();
    let arbiter = ARBITER();
    let salt1: felt252 = 111;
    let salt2: felt252 = 222;

    start_cheat_caller_address(factory_address, depositor);

    let escrow1 = factory_dispatcher.deploy_escrow(beneficiary, depositor, arbiter, salt1);
    let escrow2 = factory_dispatcher.deploy_escrow(beneficiary, depositor, arbiter, salt2);

    stop_cheat_caller_address(factory_address);

    let escrow_contracts: Array<ContractAddress> = factory_dispatcher.get_escrow_contracts();
    
    assert!(escrow_contracts.len() as usize == 2);
    assert!(escrow_contracts[0] == escrow1);
    assert!(escrow_contracts[1] == escrow2);
}
