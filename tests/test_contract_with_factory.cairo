#[starknet::contract]
mod TestContractWithFactory {
    use escrownet_contract::escrow::escrow_factory::EscrowFactory;
    use escrownet_contract::escrow::escrow_factory::IEscrowFactory;
    use starknet::{ContractAddress, class_hash::ClassHash};

    // Embed the EscrowFactory component
    component!(path: EscrowFactory, storage: escrow_factory, event: EscrowFactoryEvent);

    #[storage]
    struct Storage {
        #[substorage(v0)]
        escrow_factory: EscrowFactory::Storage,
        escrow_class_hash: ClassHash, // Store the Escrow contract's class hash
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        EscrowFactoryEvent: EscrowFactory::Event,
    }

    #[constructor]
    fn constructor(
        ref self: ContractState,
        escrow_class_hash: ClassHash,
    ) {
        self.escrow_class_hash.write(escrow_class_hash);
    }

    #[abi(embed_v0)]
    impl EscrowFactoryImpl = EscrowFactory::EscrowFactoryImpl<ContractState>;
}