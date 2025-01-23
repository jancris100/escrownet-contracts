use starknet::{ContractAddress};

#[starknet::contract]
mod EscrowContract {
    use starknet::{ContractAddress, storage::Map};
    use starknet::storage::{StoragePointerReadAccess, StoragePointerWriteAccess, StoragePathEntry,};
    use starknet::get_block_timestamp;
    use core::starknet::{get_caller_address};
    use crate::escrow::types::Escrow;
  

    #[storage]
    struct Storage {
        depositor: ContractAddress,
        benefeciary: ContractAddress,
        arbiter: ContractAddress,
        time_frame: u64,
        worth_of_asset: u256,
        client_address: ContractAddress,
        provider_address: ContractAddress,
        balance: u256,
        depositor_approve: Map::<ContractAddress, bool>,
        arbiter_approve: Map::<ContractAddress, bool>
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    pub enum Event {
        ApproveTransaction: ApproveTransaction,
    }

    #[derive(Drop, starknet::Event)]
    pub struct ApproveTransaction {
        depositor: ContractAddress,
        approval: bool,
        time_of_approval: u64,
    }

    #[constructor]
    fn constructor(
        ref self: ContractState,
        benefeciary: ContractAddress,
        depositor: ContractAddress,
        arbiter: ContractAddress
    ) {
        self.benefeciary.write(benefeciary);
        self.depositor.write(depositor);
        self.arbiter.write(arbiter);
    }



    fn get_escrow_details(ref self: ContractState, escrow_id: u256) -> Escrow {
        // Validate if the escrow exists
        let depositor = self.depositor.read();
        if depositor == 0.try_into().unwrap() {
            panic!("Escrow does not exist");
        }

        let escrow = Escrow {
            client_address: self.client_address.read(),
            provider_address: self.provider_address.read(),
            amount: self.worth_of_asset.read(),
            balance: self.balance.read(),
        };
        return escrow;
    }


    fn approve(ref self: ContractState, benefeciary: ContractAddress) {
        let caller = get_caller_address();
        // check if the address is a depositor
        let mut address = self.depositor.read();
        // check if address exist
        if address != 0.try_into().unwrap() {
            // address type is a depositor
            address = caller
        }
        // check if address is a benificary
        address = self.benefeciary.read();

        if address != 0.try_into().unwrap() {
            // address type is a beneficary
            address = caller
        }
        // map address to true
        self.depositor_approve.entry(address).write(true);
        let timestamp = get_block_timestamp();

        // Emit the event
        self
            .emit(
                ApproveTransaction {
                    depositor: address, approval: true, time_of_approval: timestamp,
                }
            );
    }
}
