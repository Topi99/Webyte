/*
En este archvo se crean algunos reportes.
Se asume que ya se crearon las tablas
correspondientes
*/


create view reportefinanciero as
    SELECT proyecto.nombre,
        gq.total              AS gastos,
        dq.total              AS recaudado,
        (dq.total - gq.total) AS diferencia
    FROM proyecto,
        (SELECT p.id         AS pid,
                sum(d.monto) AS total
        FROM proyecto p,
            donativo d
        WHERE (p.id = d.proyecto_id)
        GROUP BY p.id) dq,
        (SELECT p.id         AS pid,
                sum(g.monto) AS total
        FROM proyecto p,
            gasto g
        WHERE (p.id = g.proyecto_id)
        GROUP BY p.id) gq
    WHERE ((proyecto.id = dq.pid) AND (proyecto.id = gq.pid));

create view conteodonativos as
    SELECT p.nombre,
        p.id,
        count(*) AS donativos
    FROM proyecto p,
        donativo d
    WHERE (p.id = d.proyecto_id)
    GROUP BY p.id;

create view donativosporpersona as
    SELECT usuario.nombre,
        usuario.apellido,
        sum(donativo.monto) AS total_donado
    FROM usuario,
        donante,
        donativo
    WHERE ((usuario.id = donante.id_usuario) AND (usuario.id = donativo.donante_id))
    GROUP BY usuario.nombre, usuario.apellido;