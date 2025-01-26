use escrownet_contract::interface::iescrow::IEscrowDispatcherTrait;
use starknet::ContractAddress;

use snforge_std::{declare, ContractClassTrait, DeclareResultTrait, 
    start_cheat_caller_address,
    stop_cheat_caller_address
};
use escrownet_contract::interface::iescrow::{IEscrowDispatcher};




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

    let escrow_contract_dispatcher = IEscrowDispatcher { contract_address };

    // setup test data
    let escrow_id: u64 = 7;
    let benefeciary_address = starknet::contract_address_const::<0x123>();
    let provider_address = starknet::contract_address_const::<0x124>();
    let amount: u256 = 250;

    let escrow = escrow_contract_dispatcher.initialize_escrow(
        escrow_id,
        benefeciary_address,
        provider_address,
        amount
    );



}

