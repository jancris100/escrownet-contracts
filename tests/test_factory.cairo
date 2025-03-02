use starknet::ContractAddress;
use snforge_std::{
    declare, ContractClassTrait, DeclareResultTrait, start_cheat_caller_address,
    stop_cheat_caller_address, spy_events, EventSpyAssertionsTrait
};
use escrownet_contract::interface::iescrowfactory::IEscrowFactoryDispatcherTrait;
use escrownet_contract::interface::iescrowfactory::{IEscrowFactoryDispatcher};

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
    // Deploy EscrowFactory
    let factory_class_hash = declare("EscrowFactory").unwrap().contract_class();
    let (factory_contract_address, _) = factory_class_hash.deploy(array![]).unwrap();

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

    // Deploy Escrow Contract
    let escrow_address = factory_dispatcher.deploy_escrow(beneficiary, depositor, arbiter, salt);

    stop_cheat_caller_address(factory_address);

    // Verificar que el escrow se desplegó correctamente
    assert(escrow_address != ContractAddress::from_felt(0x0), "Escrow address is invalid.");

    // Validar que se emitió un evento de despliegue
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

    // Deploy multiple escrows
    let escrow1 = factory_dispatcher.deploy_escrow(beneficiary, depositor, arbiter, salt1);
    let escrow2 = factory_dispatcher.deploy_escrow(beneficiary, depositor, arbiter, salt2);

    stop_cheat_caller_address(factory_address);

    // Get deployed escrow contracts
    let escrow_contracts = factory_dispatcher.get_escrow_contracts();

    // Check that the correct number of escrows are stored
    assert(escrow_contracts.len() == 2, "Incorrect number of escrow contracts.");
    assert(escrow_contracts[0] == escrow1, "Escrow 1 address mismatch.");
    assert(escrow_contracts[1] == escrow2, "Escrow 2 address mismatch.");
}
