use starknet::{ContractAddress};

#[starknet::contract]
mod EscrowContract {
    use starknet::{ContractAddress, storage::Map};


    #[storage]
    struct Storage {
        depositor: ContractAddress,
        benefeciary: ContractAddress, 
        arbiter: ContractAddress,
        time_frame: u64,
        worth_of_asset: u256,
        depositor_approve: Map::<ContractAddress, bool>,
        arbiter_approve: Map::<ContractAddress, bool> 
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
    }

}
