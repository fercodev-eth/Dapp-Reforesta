// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Reciclaje is Ownable {
    
    struct ActividadReciclaje {
        string tipoMaterial;
        uint256 cantidad;
        string ubicacion;
        uint256 fecha;
        address reciclador; // Agregar quien recicló para recompensas
    }
    
    // Mappings para consultas eficientes
    mapping(uint256 => ActividadReciclaje) public actividadesReciclaje;
    mapping(address => uint256[]) public actividadesPorReciclador;
    mapping(string => uint256[]) public actividadesPorTipoMaterial;
    mapping(string => uint256) public totalPorTipoMaterial;
    
    uint256 public totalActividades;
    
    event ActividadReciclajeRegistrada(
        uint256 indexed id, 
        string tipoMaterial, 
        uint256 cantidad, 
        address indexed reciclador
    );
    
    constructor() Ownable(msg.sender) {}
    
    function registrarActividadReciclaje(
        string memory _tipoMaterial,
        uint256 _cantidad,
        string memory _ubicacion
    ) public {
        // Validaciones básicas
        require(bytes(_tipoMaterial).length > 0, "Tipo de material requerido");
        require(_cantidad > 0, "Cantidad debe ser mayor a 0");
        require(bytes(_ubicacion).length > 0, "Ubicacion requerida");
        
        totalActividades++;
        
        actividadesReciclaje[totalActividades] = ActividadReciclaje({
            tipoMaterial: _tipoMaterial,
            cantidad: _cantidad,
            ubicacion: _ubicacion,
            fecha: block.timestamp,
            reciclador: msg.sender
        });
        
        // Actualizar índices para consultas eficientes
        actividadesPorReciclador[msg.sender].push(totalActividades);
        actividadesPorTipoMaterial[_tipoMaterial].push(totalActividades);
        
        // Actualizar total por tipo de material
        totalPorTipoMaterial[_tipoMaterial] += _cantidad;
        
        emit ActividadReciclajeRegistrada(totalActividades, _tipoMaterial, _cantidad, msg.sender);
    }
    
    // Funciones de consulta para el frontend
    function obtenerActividad(uint256 _id) public view returns (ActividadReciclaje memory) {
        require(_id > 0 && _id <= totalActividades, "ID invalido");
        return actividadesReciclaje[_id];
    }
    
    function obtenerActividadesPorReciclador(address _reciclador) public view returns (uint256[] memory) {
        return actividadesPorReciclador[_reciclador];
    }
    
    function obtenerActividadesPorTipoMaterial(string memory _tipoMaterial) public view returns (uint256[] memory) {
        return actividadesPorTipoMaterial[_tipoMaterial];
    }
    
    function obtenerTotalPorTipoMaterial(string memory _tipoMaterial) public view returns (uint256) {
        return totalPorTipoMaterial[_tipoMaterial];
    }
    
    // Función para obtener total de material reciclado por usuario (para recompensas NFT)
    function obtenerTotalRecicladoPorUsuario(address _usuario) public view returns (uint256) {
        uint256[] memory actividadesUsuario = actividadesPorReciclador[_usuario];
        uint256 totalReciclado = 0;
        
        for (uint256 i = 0; i < actividadesUsuario.length; i++) {
            totalReciclado += actividadesReciclaje[actividadesUsuario[i]].cantidad;
        }
        
        return totalReciclado;
    }
    
    // Función para obtener estadísticas generales
    function obtenerEstadisticasGenerales() public view returns (
        uint256 _totalActividades,
        uint256 _totalMaterialReciclado
    ) {
        uint256 totalMaterial = 0;
        
        for (uint256 i = 1; i <= totalActividades; i++) {
            totalMaterial += actividadesReciclaje[i].cantidad;
        }
        
        return (totalActividades, totalMaterial);
    }
}