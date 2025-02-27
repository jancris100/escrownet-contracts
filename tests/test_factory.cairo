#[cfg(test)]
mod tests {
    use starknet::ContractAddress;
    use starknet::syscalls::deploy_syscall;
    use starknet::SyscallResultTrait;
    use starknet::storage::Map;
    use core::traits::TryInto;
    use snforge_std::{declare, ContractClassTrait, DeclareResultTrait};
    use array::ArrayTrait;
    use core;

    // Define el hash de clase del contrato Escrow (reemplaza con el valor real)
    const ESCROW_CONTRACT_CLASS_HASH: felt252 = 0x123;

    // Estructura para representar el estado del contrato de fábrica para las pruebas
    #[derive(Copy, Drop, Serde, PartialEq, Debug)]
    struct FactoryState {
        escrow_count: u64,
        escrow_addresses: Map<u64, ContractAddress>,
    }

    // ComponentState
    #[derive(Drop, Serde)]
    struct ComponentState<T> {
        state: T
    }

    // Función para desplegar el contrato EscrowFactory
    fn deploy_escrow_factory() -> ContractAddress {
        let contract = declare("EscrowFactory");
        let class_hash = contract.unwrap().class_hash();

        let mut constructor_calldata: Array<felt252> = array![]; // No constructor args
        let (contract_address, _) = deploy_syscall(
            class_hash, 0, constructor_calldata.span(), false
        )
            .unwrap_syscall();

        contract_address
    }

    // Función auxiliar para crear direcciones de contrato
    fn create_contract_address(value: felt252) -> ContractAddress {
        ContractAddress::new(value).unwrap()
    }

    #[test]
    fn test_deploy_escrow() {
        // Configuración
        let escrow_factory_address = deploy_escrow_factory();
        let beneficiary = create_contract_address(100_felt252);
        let depositor = create_contract_address(200_felt252);
        let arbiter = create_contract_address(300_felt252);
        let salt: felt252 = 12345_felt252;

        // Ejecución: Llama a la función deploy_escrow
        let mut factory_state = FactoryState {
            escrow_count: 0, escrow_addresses: Default::default()
        };

        let escrow_address = super::EscrowFactory::EscrowFactoryImpl::deploy_escrow(
            ComponentState { state: factory_state }, beneficiary, depositor, arbiter, salt
        );

        // Verificación
        assert(escrow_address != ContractAddress::default(), 'Escrow address cannot be zero');
        // No es posible verificar directamente el storage aquí sin acceso al contrato desplegado
    // Este test se centra en asegurar que deploy_escrow retorna una dirección no nula
    }

    #[test]
    fn test_get_escrow_contracts() {
        // Configuración
        let escrow_factory_address = deploy_escrow_factory();
        let beneficiary = create_contract_address(100_felt252);
        let depositor = create_contract_address(200_felt252);
        let arbiter = create_contract_address(300_felt252);
        let salt: felt252 = 12345_felt252;

        // Ejecución: Despliega algunos contratos de Escrow
        let mut factory_state = FactoryState {
            escrow_count: 0, escrow_addresses: Default::default()
        };

        let escrow_address1 = super::EscrowFactory::EscrowFactoryImpl::deploy_escrow(
            ComponentState { state: factory_state }, beneficiary, depositor, arbiter, salt
        );

        factory_state.escrow_count = 1;

        let escrow_address2 = super::EscrowFactory::EscrowFactoryImpl::deploy_escrow(
            ComponentState { state: factory_state }, beneficiary, depositor, arbiter, salt
        );
        factory_state.escrow_count = 2;

        // Ejecución: Llama a la función get_escrow_contracts
        let escrow_contracts = super::EscrowFactory::EscrowFactoryImpl::get_escrow_contracts(
            ComponentState { state: factory_state }
        );

        // Verificación
        assert(escrow_contracts.len() == 0, 'Should be 0 Escrow contracts');
    }
}
