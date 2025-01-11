use starknet::{ContractAddress};

#[starknet::contract]
mod EscrowContract {
    use starknet::{ContractAddress};


    #[storage]
    struct Storage {
        depositor: ContractAddress,
        benefeciary: ContractAddress, 
        arbiter: ContractAddress
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
    }

}
