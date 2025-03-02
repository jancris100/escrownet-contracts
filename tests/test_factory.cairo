#[cfg(test)]
mod tests {
    use starknet::testing::deploy_mock_contract;
    use starknet::ContractAddress;
    use core::starknet::{assert, array};

    use super::EscrowFactory;

    #[test]
    fn test_deploy_escrow() {
        // 1️⃣ Desplegamos el contrato de fábrica
        let mut factory = EscrowFactory::deploy();

        // 2️⃣ Definimos direcciones de prueba
        let beneficiary = ContractAddress::from_felt(0x1);
        let depositor = ContractAddress::from_felt(0x2);
        let arbiter = ContractAddress::from_felt(0x3);
        let salt = 12345;

        // 3️⃣ Llamamos a deploy_escrow
        let escrow_address = factory.deploy_escrow(beneficiary, depositor, arbiter, salt);

        // 4️⃣ Verificamos que la dirección devuelta no es cero
        assert!(escrow_address != ContractAddress::from_felt(0x0));

        // 5️⃣ Verificamos que la dirección se guardó correctamente
        let escrow_contracts = factory.get_escrow_contracts();
        assert!(escrow_contracts.len() == 1);
        assert!(escrow_contracts[0] == escrow_address);
    }

    #[test]
    fn test_get_escrow_contracts() {
        // 1️⃣ Desplegamos el contrato de fábrica
        let mut factory = EscrowFactory::deploy();

        // 2️⃣ Desplegamos varios contratos de escrow
        let escrow1 = factory.deploy_escrow(ContractAddress::from_felt(0x1), ContractAddress::from_felt(0x2), ContractAddress::from_felt(0x3), 111);
        let escrow2 = factory.deploy_escrow(ContractAddress::from_felt(0x4), ContractAddress::from_felt(0x5), ContractAddress::from_felt(0x6), 222);
        let escrow3 = factory.deploy_escrow(ContractAddress::from_felt(0x7), ContractAddress::from_felt(0x8), ContractAddress::from_felt(0x9), 333);

        // 3️⃣ Obtenemos la lista de contratos desplegados
        let escrow_contracts = factory.get_escrow_contracts();

        // 4️⃣ Verificamos que las direcciones están en la lista
        assert!(escrow_contracts.len() == 3);
        assert!(escrow_contracts[0] == escrow1);
        assert!(escrow_contracts[1] == escrow2);
        assert!(escrow_contracts[2] == escrow3);
    }
}
