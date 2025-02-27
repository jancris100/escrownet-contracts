#[cfg(test)]
mod tests {
    use starknet::ContractAddress;
    use starknet::syscalls::deploy_syscall;
    use starknet::SyscallResultTrait;
    use snforge_std::{declare, deploy, call_contract, ContractClassTrait, DeclareResultTrait};

    // Hash de clase del contrato Escrow (reemplazar con el real)
    const ESCROW_CONTRACT_CLASS_HASH: felt252 = 0x123;

    // Función auxiliar para crear direcciones de contrato
    fn create_contract_address(value: felt252) -> ContractAddress {
        ContractAddress::new(value).unwrap()
    }

    // 📌 Función para desplegar el contrato EscrowFactory
    fn deploy_escrow_factory() -> ContractAddress {
        let contract = declare("EscrowFactory").unwrap();
        let class_hash = contract.class_hash();

        let constructor_calldata = array![]; // Sin argumentos en el constructor
        let contract_address = deploy(class_hash, constructor_calldata, false).unwrap();

        contract_address
    }

    #[test]
    fn test_deploy_escrow() {
        // 📌 1. Configuración: desplegar el contrato EscrowFactory
        let escrow_factory_address = deploy_escrow_factory();

        // Crear direcciones de prueba
        let beneficiary = create_contract_address(100_felt252);
        let depositor = create_contract_address(200_felt252);
        let arbiter = create_contract_address(300_felt252);
        let salt: felt252 = 12345_felt252;

        // 📌 2. Llamar a la función `deploy_escrow`
        let escrow_address: ContractAddress = call_contract(
            escrow_factory_address, "deploy_escrow", (beneficiary, depositor, arbiter, salt),
        )
            .unwrap();

        // 📌 3. Verificar que se ha desplegado correctamente
        assert(escrow_address != ContractAddress::default(), "Escrow address cannot be zero");
    }

    #[test]
    fn test_get_escrow_contracts() {
        // 📌 1. Configuración: desplegar el contrato EscrowFactory
        let escrow_factory_address = deploy_escrow_factory();

        // Crear direcciones de prueba
        let beneficiary = create_contract_address(100_felt252);
        let depositor = create_contract_address(200_felt252);
        let arbiter = create_contract_address(300_felt252);
        let salt: felt252 = 12345_felt252;

        // 📌 2. Desplegar dos contratos Escrow
        let _escrow_address1: ContractAddress = call_contract(
            escrow_factory_address, "deploy_escrow", (beneficiary, depositor, arbiter, salt),
        )
            .unwrap();

        let _escrow_address2: ContractAddress = call_contract(
            escrow_factory_address,
            "deploy_escrow",
            (
                beneficiary, depositor, arbiter, salt + 1_felt252
            ), // Diferente salt para generar otra dirección
        )
            .unwrap();

        // 📌 3. Llamar a `get_escrow_contracts`
        let escrow_contracts: Array<ContractAddress> = call_contract(
            escrow_factory_address, "get_escrow_contracts", (),
        )
            .unwrap();

        // 📌 4. Verificar que los contratos han sido registrados correctamente
        assert(escrow_contracts.len() == 2, "Should be 2 Escrow contracts");
    }
}
