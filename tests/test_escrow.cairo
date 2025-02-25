use escrownet_contract::interface::iescrow::IEscrowDispatcherTrait;
use starknet::ContractAddress;

use snforge_std::{
    declare, ContractClassTrait, DeclareResultTrait, start_cheat_caller_address,
    stop_cheat_caller_address, start_cheat_block_timestamp, stop_cheat_block_timestamp, spy_events,
    EventSpyAssertionsTrait,
};
use escrownet_contract::interface::iescrow::{IEscrowDispatcher};
use escrownet_contract::escrow::errors::Errors;

fn BENEFICIARY() -> ContractAddress {
    'benefeciary'.try_into().unwrap()
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
#[test]
fn test_setup() {
    let contract_address = __setup__();

    println!("Deployed address: {:?}", contract_address);
}

#[test]
fn test_initialize_escrow() {
    let contract_address = __setup__();
    println!("Deployed address: {:?}", contract_address);

    let escrow_contract_dispatcher = IEscrowDispatcher { contract_address };
    let mut spy = spy_events();

    // setup test data
    let escrow_id: u64 = 7;
    let benefeciary_address = BENEFICIARY();
    let provider_address = starknet::contract_address_const::<0x124>();
    let amount: u256 = 250;

    let depositor = DEPOSITOR();

    start_cheat_caller_address(contract_address, depositor);

    escrow_contract_dispatcher
        .initialize_escrow(escrow_id, benefeciary_address, provider_address, amount);

    let escrow_data = escrow_contract_dispatcher.get_escrow_details(7);

    assert(escrow_data.amount == 250, Errors::INVALID_AMOUNT);

    stop_cheat_caller_address(contract_address);
}
// #[test]
// fn test_depositor_approve() {
//     let contract_address = __setup__();
//     let escrow_contract_dispatcher = IEscrowDispatcher { contract_address };
//     let mut spy = spy_events();

//     // Test data
//     let escrow_id: u64 = 7;
//     let beneficiary_address = BENEFICIARY();
//     let provider_address = starknet::contract_address_const::<0x124>();
//     let amount: u256 = 250;

//     // Impersonate depositor
//     start_cheat_caller_address(contract_address, DEPOSITOR());

//     // let token = IERC20Dispatcher { contract_address: token_address };
//     // token.transfer_from(caller_address, contract_address, amount);

//     // Initialize and fund escrow
//     escrow_contract_dispatcher
//         .initialize_escrow(escrow_id, beneficiary_address, provider_address, amount);
//     escrow_contract_dispatcher.fund_escrow(escrow_id, amount, token_address);

//     // Approve escrow
//     escrow_contract_dispatcher.depositor_approve(escrow_id);

//     // Verify approval
//     let (depositor_approved, _) = escrow_contract_dispatcher.check_approvals(escrow_id);
//     assert(depositor_approved, 'Depositor approval failed');

//     // Verify event emission
//     spy
//         .assert_event::<
//             DepositorApproved,
//         >(
//             1,
//             |event| {
//                 assert(event.depositor == DEPOSITOR(), "Invalid depositor address");
//                 assert(event.escrow_id == escrow_id, "Invalid escrow ID");
//             },
//         );

//     stop_cheat_caller_address(contract_address);
// }

// #[test]
// fn test_arbiter_approve() {
//     let contract_address = __setup__();
//     let escrow_contract_dispatcher = IEscrowDispatcher { contract_address };
//     let mut spy = spy_events();

//     // Test data
//     let escrow_id: u64 = 7;
//     let beneficiary_address = BENEFICIARY();
//     let provider_address = starknet::contract_address_const::<0x124>();
//     let amount: u256 = 250;

//     // Impersonate depositor
//     start_cheat_caller_address(contract_address, DEPOSITOR());

//     // Initialize and fund escrow
//     escrow_contract_dispatcher
//         .initialize_escrow(escrow_id, beneficiary_address, provider_address, amount);
//     escrow_contract_dispatcher.fund_escrow(escrow_id, amount, token_address);

//     // Impersonate arbiter
//     start_cheat_caller_address(contract_address, ARBITER());

//     // Approve escrow
//     escrow_contract_dispatcher.arbiter_approve(escrow_id);

//     // Verify approval
//     let (_, arbiter_approved) = escrow_contract_dispatcher.check_approvals(escrow_id);
//     assert(arbiter_approved, 'Arbiter approval failed');

//     // Verify event emission
//     spy
//         .assert_event::<
//             ArbiterApproved,
//         >(
//             1,
//             |event| {
//                 assert(event.arbiter == ARBITER(), "Invalid arbiter address");
//                 assert(event.escrow_id == escrow_id, "Invalid escrow ID");
//             },
//         );

//     stop_cheat_caller_address(contract_address);
// }

// #[test]
// fn test_release_funds() {
//     let contract_address = __setup__();
//     let escrow_contract_dispatcher = IEscrowDispatcher { contract_address };
//     let mut spy = spy_events();

//     // Test data
//     let escrow_id: u64 = 7;
//     let beneficiary_address = BENEFICIARY();
//     let provider_address = starknet::contract_address_const::<0x124>();
//     let amount: u256 = 250;

//     // Impersonate depositor
//     start_cheat_caller_address(contract_address, DEPOSITOR());

//     // Initialize and fund escrow
//     escrow_contract_dispatcher
//         .initialize_escrow(escrow_id, beneficiary_address, provider_address, amount);
//     escrow_contract_dispatcher.fund_escrow(escrow_id, amount, token_address);

//     // Approve escrow
//     escrow_contract_dispatcher.depositor_approve(escrow_id);

//     // Impersonate arbiter
//     start_cheat_caller_address(contract_address, ARBITER());
//     escrow_contract_dispatcher.arbiter_approve(escrow_id);

//     // Release funds
//     escrow_contract_dispatcher.release_funds(escrow_id, token_address);

//     // Verify event emission
//     spy
//         .assert_event::<
//             FundsReleased,
//         >(
//             1,
//             |event| {
//                 assert(event.escrow_id == escrow_id, "Invalid escrow ID");
//                 assert(event.beneficiary == beneficiary_address, "Invalid beneficiary address");
//                 assert(event.amount == amount, "Invalid amount");
//             },
//         );

//     stop_cheat_caller_address(contract_address);
// }

// #[test]
// fn test_missing_approvals() {
//     let contract_address = __setup__();
//     let escrow_contract_dispatcher = IEscrowDispatcher { contract_address };

//     // Test data
//     let escrow_id: u64 = 7;
//     let beneficiary_address = BENEFICIARY();
//     let provider_address = starknet::contract_address_const::<0x124>();
//     let amount: u256 = 250;

//     // Impersonate depositor
//     start_cheat_caller_address(contract_address, DEPOSITOR());

//     // Initialize and fund escrow
//     escrow_contract_dispatcher
//         .initialize_escrow(escrow_id, beneficiary_address, provider_address, amount);
//     escrow_contract_dispatcher.fund_escrow(escrow_id, amount, token_address);

//     // Attempt to release funds without arbiter approval
//     let result = escrow_contract_dispatcher.release_funds(escrow_id, token_address);
//     assert(result.is_err(), 'Expected error due to missing arbiter approval');

//     stop_cheat_caller_address(contract_address);
// }


