use starknet::ContractAddress;

use snforge_std::{declare, ContractClassTrait, DeclareResultTrait};


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

