// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./Arborizacion.sol";
import "./Reciclaje.sol";
import "./RecompensasNFT.sol";

contract DAppReforesta {
    
    // Instancias de contratos
    Arborizacion public arborizacion;
    Reciclaje public reciclaje;
    RecompensasNFT public recompensasNFT;
    
    // Variables de control
    address public owner;
    bool public sistemaPausado;
    
    // Eventos principales
    event ContratosDesplegados(
        address arborizacion,
        address reciclaje,
        address recompensasNFT
    );
    
    event AccionCompleta(
        address indexed usuario,
        string tipoAccion,
        uint256 timestamp
    );
    
    event RecompensaAutomatica(
        address indexed usuario,
        uint256 nftsOtorgados,
        string razon
    );
    
    // Modificadores
    modifier soloOwner() {
        require(msg.sender == owner, "Solo el propietario puede ejecutar esta funcion");
        _;
    }
    
    modifier sistemaActivo() {
        require(!sistemaPausado, "Sistema pausado temporalmente");
        _;
    }
    
    constructor() {
        owner = msg.sender;
        sistemaPausado = false;
        
        // Desplegar contratos
        arborizacion = new Arborizacion();
        reciclaje = new Reciclaje();
        recompensasNFT = new RecompensasNFT();
        
        emit ContratosDesplegados(
            address(arborizacion),
            address(reciclaje),
            address(recompensasNFT)
        );
    }
    
    // Función principal para plantar árbol con lógica de recompensas
    function plantarArbol(
        string memory _especie,
        string memory _clasificacion,
        uint256 _altura,
        uint256 _tallo,
        string memory _distrito,
        string memory _comunidad,
        string memory _coordenadasGPS
    ) public sistemaActivo {
        // Plantar el árbol
        arborizacion.plantarArbol(
            _especie,
            _clasificacion,
            _altura,
            _tallo,
            _distrito,
            _comunidad,
            _coordenadasGPS
        );
        
        // Actualizar contadores y verificar recompensas
        _actualizarRecompensas(msg.sender);
        
        emit AccionCompleta(msg.sender, "PLANTACION", block.timestamp);
    }
    
    // Función principal para registrar reciclaje con lógica de recompensas
    function registrarActividadReciclaje(
        string memory _tipoMaterial,
        uint256 _cantidad,
        string memory _ubicacion
    ) public sistemaActivo {
        // Registrar actividad de reciclaje
        reciclaje.registrarActividadReciclaje(_tipoMaterial, _cantidad, _ubicacion);
        
        // Actualizar contadores y verificar recompensas
        _actualizarRecompensas(msg.sender);
        
        emit AccionCompleta(msg.sender, "RECICLAJE", block.timestamp);
    }
    
    // Función interna para actualizar recompensas automáticamente
    function _actualizarRecompensas(address _usuario) internal {
        // Obtener totales actuales del usuario
        uint256 totalArboles = arborizacion.obtenerArbolesPorPlantador(_usuario).length;
        uint256 totalMaterialReciclado = reciclaje.obtenerTotalRecicladoPorUsuario(_usuario);
        
        // Actualizar contadores en el contrato de NFT
        recompensasNFT.actualizarContadores(_usuario, totalArboles, totalMaterialReciclado);
        
        // Verificar si califica para nuevas recompensas
        (bool elegible, uint256 recompensasPendientes) = recompensasNFT.verificarElegibilidadRecompensa(_usuario);
        
        if (elegible && recompensasPendientes > 0) {
            // Otorgar las recompensas pendientes
            for (uint256 i = 0; i < recompensasPendientes; i++) {
                string memory metadataURI = _generarMetadataURI(_usuario, totalArboles, totalMaterialReciclado);
                recompensasNFT.otorgarRecompensa(_usuario, metadataURI);
            }
            
            emit RecompensaAutomatica(_usuario, recompensasPendientes, "Logros alcanzados");
        }
    }
    
    // Función para generar URI de metadatos (simplificada)
    function _generarMetadataURI(
        address _usuario,
        uint256 _arboles,
        uint256 _material
    ) internal pure returns (string memory) {
        // En implementación real, esto generaría un JSON con metadatos del NFT
        // Por simplicidad, retornamos un string básico
        return string(abi.encodePacked(
            "https://api.dappreforesta.com/nft/",
            _addressToString(_usuario),
            "/",
            _uint256ToString(_arboles + _material)
        ));
    }
    
    // Función manual para otorgar recompensas (solo owner)
    function otorgarRecompensa(
        address _beneficiario, 
        string memory _tokenURI
    ) public soloOwner {
        recompensasNFT.otorgarRecompensa(_beneficiario, _tokenURI);
    }
    
    // Funciones de consulta integradas
    function obtenerEstadisticasUsuario(address _usuario) public view returns (
        uint256 _totalArboles,
        uint256 _totalMaterialReciclado,
        uint256 _totalNFTs,
        uint256 _recompensasPendientes
    ) {
        uint256 totalArboles = arborizacion.obtenerArbolesPorPlantador(_usuario).length;
        uint256 totalMaterial = reciclaje.obtenerTotalRecicladoPorUsuario(_usuario);
        
        (,, uint256 totalNFTs) = recompensasNFT.obtenerContadoresUsuario(_usuario);
        (, uint256 recompensasPendientes) = recompensasNFT.verificarElegibilidadRecompensa(_usuario);
        
        return (totalArboles, totalMaterial, totalNFTs, recompensasPendientes);
    }
    
    function obtenerEstadisticasGenerales() public view returns (
        uint256 _totalArboles,
        uint256 _totalActividades,
        uint256 _totalNFTs
    ) {
        uint256 totalArboles = arborizacion.totalArboles();
        (uint256 totalActividades,) = reciclaje.obtenerEstadisticasGenerales();
        uint256 totalNFTs = recompensasNFT.obtenerRecompensa();
        
        return (totalArboles, totalActividades, totalNFTs);
    }
    
    // Funciones de administración
    function pausarSistema() public soloOwner {
        sistemaPausado = true;
    }
    
    function reanudarSistema() public soloOwner {
        sistemaPausado = false;
    }
    
    function transferirPropiedad(address _nuevoOwner) public soloOwner {
        require(_nuevoOwner != address(0), "Nueva direccion invalida");
        owner = _nuevoOwner;
    }
    
    // Funciones de utilidad
    function _addressToString(address _addr) internal pure returns (string memory) {
        bytes32 value = bytes32(uint256(uint160(_addr)));
        bytes memory alphabet = "0123456789abcdef";
        bytes memory str = new bytes(42);
        str[0] = '0';
        str[1] = 'x';
        for (uint256 i = 0; i < 20; i++) {
            str[2+i*2] = alphabet[uint8(value[i + 12] >> 4)];
            str[3+i*2] = alphabet[uint8(value[i + 12] & 0x0f)];
        }
        return string(str);
    }
    
    function _uint256ToString(uint256 _value) internal pure returns (string memory) {
        if (_value == 0) return "0";
        
        uint256 temp = _value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        
        bytes memory buffer = new bytes(digits);
        while (_value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(_value % 10)));
            _value /= 10;
        }
        
        return string(buffer);
    }
}