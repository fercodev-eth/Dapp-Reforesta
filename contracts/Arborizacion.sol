// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Arborizacion is Ownable {
    
    struct Arbol {
        string especie;
        string clasificacion;
        uint256 altura;
        uint256 tallo;
        string distrito;
        string comunidad;
        string coordenadasGPS;
        uint256 fechaPlantacion;
        address plantador; // Agregar quien plantó para recompensas
    }
    
    // Mappings para consultas eficientes
    mapping(uint256 => Arbol) public arboles;
    mapping(address => uint256[]) public arbolesPorPlantador;
    mapping(string => uint256[]) public arbolesPorDistrito;
    
    uint256 public totalArboles;
    
    event ArbolPlantado(
        uint256 indexed id, 
        string especie, 
        string distrito, 
        address indexed plantador
    );
    
    constructor() Ownable(msg.sender) {}
    
    function plantarArbol(
        string memory _especie,
        string memory _clasificacion,
        uint256 _altura,
        uint256 _tallo,
        string memory _distrito,
        string memory _comunidad,
        string memory _coordenadasGPS
    ) public {
        // Validaciones básicas
        require(bytes(_especie).length > 0, "Especie requerida");
        require(_altura > 0, "Altura debe ser mayor a 0");
        require(_tallo > 0, "Tallo debe ser mayor a 0");
        require(bytes(_distrito).length > 0, "Distrito requerido");
        
        totalArboles++;
        
        arboles[totalArboles] = Arbol({
            especie: _especie,
            clasificacion: _clasificacion,
            altura: _altura,
            tallo: _tallo,
            distrito: _distrito,
            comunidad: _comunidad,
            coordenadasGPS: _coordenadasGPS,
            fechaPlantacion: block.timestamp,
            plantador: msg.sender
        });
        
        // Actualizar índices para consultas eficientes
        arbolesPorPlantador[msg.sender].push(totalArboles);
        arbolesPorDistrito[_distrito].push(totalArboles);
        
        emit ArbolPlantado(totalArboles, _especie, _distrito, msg.sender);
    }
    
    function calcularCapturaCarbono(uint256 _id) public view returns (uint256) {
        require(_id > 0 && _id <= totalArboles, "ID invalido");
        Arbol memory arbol = arboles[_id];
        
        // Fórmula mejorada pero simple
        return (arbol.altura * arbol.tallo) / 100;
    }
    
    // Funciones de consulta para el frontend
    function obtenerArbol(uint256 _id) public view returns (Arbol memory) {
        require(_id > 0 && _id <= totalArboles, "ID invalido");
        return arboles[_id];
    }
    
    function obtenerArbolesPorPlantador(address _plantador) public view returns (uint256[] memory) {
        return arbolesPorPlantador[_plantador];
    }
    
    function obtenerArbolesPorDistrito(string memory _distrito) public view returns (uint256[] memory) {
        return arbolesPorDistrito[_distrito];
    }
}