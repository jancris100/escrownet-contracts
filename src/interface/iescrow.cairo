use starknet::ContractAddress;
#[starknet::interface]
pub trait IEscrowContract<TContractState> {
    fn approve(ref self: TContractState, benefeciary: ContractAddress);
    fn get_depositor(self: @TContractState) -> ContractAddress;
}

