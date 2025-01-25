use starknet::ContractAddress;
use escrow::types::Escrow;


#[starknet::interface]
pub trait IEscrow<TContractState> {
    fn get_escrow(self: @TContractState, escrow_id: u256) -> Escrow;
}
