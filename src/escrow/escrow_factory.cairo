// SPDX-License-Identifier: MIT
pub use starknet::{
    ContractAddress, class_hash::ClassHash, syscalls::deploy_syscall, SyscallResultTrait,
};

#[starknet::interface]
pub trait IEscrowFactory<TContractState> {
    fn deploy_escrow(
        ref self: TContractState,
        beneficiary: ContractAddress,
        depositor: ContractAddress,
        arbiter: ContractAddress,
        salt: felt252,
    ) -> ContractAddress;

    fn get_escrow_contracts(ref self: TContractState) -> Array<ContractAddress>;
}

#[starknet::contract]
pub mod EscrowFactory {
    use super::IEscrowFactory;
    use starknet::{
        ContractAddress, class_hash::ClassHash, syscalls::deploy_syscall, SyscallResultTrait,
        storage::{Map, StoragePathEntry},
    };
    use core::traits::{TryInto, Into};
    use core::starknet::storage::{StoragePointerReadAccess, StoragePointerWriteAccess};

    const ESCROW_CONTRACT_CLASS_HASH: felt252 = 0x123;

    #[storage]
    struct Storage {
        escrow_count: u64,
        escrow_addresses: Map<u64, ContractAddress>,
        escrow_class_hash: ClassHash,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    pub enum Event {
        EscrowDeployed: EscrowDeployed
    }

    #[derive(Drop, starknet::Event)]
    pub struct EscrowDeployed {
        pub beneficiary: ContractAddress,
        pub depositor: ContractAddress,
        pub arbiter: ContractAddress,
        pub escrow_address: ContractAddress,
        pub salt: felt252,
    }

    #[constructor]
    fn constructor(ref self: ContractState, escrow_class_hash: ClassHash) {
        self.escrow_class_hash.write(escrow_class_hash);
    }

    #[abi(embed_v0)]
    impl EscrowFactoryImpl of super::IEscrowFactory<ContractState> {
        fn deploy_escrow(
            ref self: ContractState,
            beneficiary: ContractAddress,
            depositor: ContractAddress,
            arbiter: ContractAddress,
            salt: felt252,
        ) -> ContractAddress {
            let escrow_id = self.escrow_count.read() + 1;

            let mut constructor_calldata: Array<felt252> = array![
                beneficiary.into(), depositor.into(), arbiter.into(),
            ];

            let class_hash: ClassHash = self.escrow_class_hash.read();

            let result = deploy_syscall(class_hash, salt, constructor_calldata.span(), true);
            let (escrow_address, _) = result.unwrap_syscall();

            // Guardar dirección del nuevo contrato
            self.escrow_addresses.write(escrow_id, escrow_address);
            self.escrow_count.write(escrow_id);

            // Emitir evento
            self
                .emit(
                    Event::EscrowDeployed(
                        EscrowDeployed { beneficiary, depositor, arbiter, escrow_address, salt, }
                    )
                );

            escrow_address
        }


        fn get_escrow_contracts(ref self: ContractState,) -> Array<ContractAddress> {
            let escrow_count = self.escrow_count.read();
            let mut escrow_addresses: Array<ContractAddress> = array![];

            let mut i: u64 = 1;
            loop {
                if i > escrow_count {
                    break;
                }
                escrow_addresses.append(self.escrow_addresses.read(i));
                i += 1;
            };

            escrow_addresses
        }
    }
}
