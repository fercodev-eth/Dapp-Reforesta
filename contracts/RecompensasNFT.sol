// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RecompensasNFT is ERC721URIStorage, Ownable {
    
    uint256 public tokenCount;
    
    // Estructura para metadatos de logros
    struct LogroNFT {
        uint256 arbolesPlantados;
        uint256 materialReciclado;
        uint256 fechaLogro;
        string tipoLogro; // "PLANTACION", "RECICLAJE", "MIXTO"
        string descripcion;
    }
    
    // Mappings para gestión de NFTs
    mapping(uint256 => LogroNFT) public logrosNFT;
    mapping(address => uint256[]) public nftsPorUsuario;
    mapping(address => uint256) public totalArbolesUsuario;
    mapping(address => uint256) public totalReciclajeUsuario;
    
    // Eventos
    event RecompensaOtorgada(
        address indexed usuario,
        uint256 indexed tokenId,
        string tipoLogro,
        uint256 arbolesPlantados,
        uint256 materialReciclado
    );
    
    event LogroAlcanzado(
        address indexed usuario,
        string tipoLogro,
        uint256 valor
    );
    
    constructor() ERC721("EcoReforest NFT", "ERFST") Ownable(msg.sender) {}
    
    // Función principal para otorgar recompensas (solo owner - llamada desde contrato main)
    function otorgarRecompensa(
        address _usuario, 
        string memory _metadatosURI
    ) public onlyOwner {
        require(_usuario != address(0), "Usuario invalido");
        require(bytes(_metadatosURI).length > 0, "Metadatos URI requeridos");
        
        tokenCount++;
        _mint(_usuario, tokenCount);
        _setTokenURI(tokenCount, _metadatosURI);
        
        // Registrar en índices
        nftsPorUsuario[_usuario].push(tokenCount);
        
        // Crear registro de logro con datos actuales del usuario
        logrosNFT[tokenCount] = LogroNFT({
            arbolesPlantados: totalArbolesUsuario[_usuario],
            materialReciclado: totalReciclajeUsuario[_usuario],
            fechaLogro: block.timestamp,
            tipoLogro: _determinarTipoLogro(totalArbolesUsuario[_usuario], totalReciclajeUsuario[_usuario]),
            descripcion: "Logro de reforestacion y reciclaje"
        });
        
        emit RecompensaOtorgada(
            _usuario, 
            tokenCount, 
            logrosNFT[tokenCount].tipoLogro,
            totalArbolesUsuario[_usuario],
            totalReciclajeUsuario[_usuario]
        );
    }
    
    // Función para actualizar contadores de usuarios (llamada desde contrato main)
    function actualizarContadores(
        address _usuario,
        uint256 _arbolesPlantados,
        uint256 _materialReciclado
    ) public onlyOwner {
        totalArbolesUsuario[_usuario] = _arbolesPlantados;
        totalReciclajeUsuario[_usuario] = _materialReciclado;
        
        // Verificar si califica para nuevas recompensas
        uint256 recompensasCalculadas = calcularRecompensa(_arbolesPlantados, _materialReciclado);
        uint256 nftsActuales = nftsPorUsuario[_usuario].length;
        
        if (recompensasCalculadas > nftsActuales) {
            emit LogroAlcanzado(_usuario, "NUEVO_LOGRO", recompensasCalculadas - nftsActuales);
        }
    }
    
    // Función original del documento mejorada
    function calcularRecompensa(
        uint256 _arbolesPlantados, 
        uint256 _materialReciclado
    ) public pure returns (uint256) {
        // Lógica original: 1 árbol plantado = 1 NFT, 10 unidades de material reciclado = 1 NFT
        return _arbolesPlantados + (_materialReciclado / 10);
    }
    
    // Función para determinar tipo de logro
    function _determinarTipoLogro(
        uint256 _arboles, 
        uint256 _material
    ) internal pure returns (string memory) {
        if (_arboles > 0 && _material > 0) {
            return "MIXTO";
        } else if (_arboles > 0) {
            return "PLANTACION";
        } else if (_material > 0) {
            return "RECICLAJE";
        } else {
            return "INICIAL";
        }
    }
    
    // Funciones de consulta para el frontend
    function obtenerNFTsPorUsuario(address _usuario) public view returns (uint256[] memory) {
        return nftsPorUsuario[_usuario];
    }
    
    function obtenerLogro(uint256 _tokenId) public view returns (LogroNFT memory) {
        require(_tokenId > 0 && _tokenId <= tokenCount, "Token no existe");
        return logrosNFT[_tokenId];
    }
    
    function obtenerContadoresUsuario(address _usuario) public view returns (
        uint256 _totalArboles,
        uint256 _totalMaterial,
        uint256 _totalNFTs
    ) {
        return (
            totalArbolesUsuario[_usuario],
            totalReciclajeUsuario[_usuario],
            nftsPorUsuario[_usuario].length
        );
    }
    
    function verificarElegibilidadRecompensa(address _usuario) public view returns (
        bool _elegible,
        uint256 _recompensasPendientes
    ) {
        uint256 recompensasCalculadas = calcularRecompensa(
            totalArbolesUsuario[_usuario],
            totalReciclajeUsuario[_usuario]
        );
        uint256 nftsActuales = nftsPorUsuario[_usuario].length;
        
        if (recompensasCalculadas > nftsActuales) {
            return (true, recompensasCalculadas - nftsActuales);
        } else {
            return (false, 0);
        }
    }
    
    // Función original del documento
    function obtenerRecompensa() public view returns (uint256) {
        return tokenCount;
    }
    
    // Función para obtener estadísticas generales
    function obtenerEstadisticasGenerales() public view returns (
        uint256 _totalTokens,
        uint256 _totalUsuarios
    ) {
        // Contar usuarios únicos sería costoso en gas, por simplicidad retornamos tokenCount
        return (tokenCount, tokenCount); // Simplificación para evitar loops costosos
    }
}