// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract Reciclaje {
    struct ActividadReciclaje {
        string tipoMaterial;
        uint cantidad;
        string ubicacion;
        uint fecha;
    }

    mapping(uint => ActividadReciclaje) public actividadesReciclaje;
    uint public totalActividades;

    event ActividadReciclajeRegistrada(uint id, string tipoMaterial, uint cantidad);

    function registrarActividadReciclaje(
        string memory tipoMaterial,
        uint cantidad,
        string memory ubicacion
    ) public {
        totalActividades++;
        actividadesReciclaje[totalActividades] = ActividadReciclaje({
            tipoMaterial: tipoMaterial,
            cantidad: cantidad,
            ubicacion: ubicacion,
            fecha: block.timestamp
        });
        emit ActividadReciclajeRegistrada(totalActividades, tipoMaterial, cantidad);
    }
}