// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract Arborizacion {
    struct Arbol {
        string especie;
        string clasificacion;
        uint altura;
        uint tallo;
        string distrito;
        string comunidad;
        string coordenadasGPS;
        uint fechaPlantacion;
    }

    mapping(uint => Arbol) public arboles;
    uint public totalArboles;

    event ArbolPlantado(uint id, string especie, string distrito);

    function plantarArbol(
        string memory especie,
        string memory clasificacion,
        uint altura,
        uint tallo,
        string memory distrito,
        string memory comunidad,
        string memory coordenadasGPS
    ) public {
        totalArboles++;
        arboles[totalArboles] = Arbol({
            especie: especie,
            clasificacion: clasificacion,
            altura: altura,
            tallo: tallo,
            distrito: distrito,
            comunidad: comunidad,
            coordenadasGPS: coordenadasGPS,
            fechaPlantacion: block.timestamp
        });
        emit ArbolPlantado(totalArboles, especie, distrito);
    }

    function calcularCapturaCarbono(uint id) public view returns (uint) {
        Arbol memory arbol = arboles[id];
        // Fórmula simplificada para cálculo de captura de carbono
        return (arbol.altura * arbol.tallo) / 100;
    }
}