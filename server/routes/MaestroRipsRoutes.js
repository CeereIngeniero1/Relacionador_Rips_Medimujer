const { Request, TYPES } = require('tedious');
const Router = require('express').Router;
const connection = require('../db');

const router = Router();


router.get('/MaestropruebaHC', async (req, res) => {

    try {
        const request = new Request(
            `SELECT TOP(10) [Id Evaluación Entidad],
            [Documento Entidad], 
            [Fecha Evaluación Entidad] 
            FROM [Evaluación Entidad]`,
            (err) => {
                if (err) {
                    console.error(`Error de ejecución: ${err}`);
                    // En caso de error, enviamos una respuesta y salimos de la función
                    if (!res.headersSent) {
                        res.status(500).send('Error interno del servidor');
                    }
                }
            }
        );

        const resultados = [];

        request.on('row', (columns) => {
            const hc = {
                idevaluacion: columns[0].value,
                fechaevaluacion: columns[1].value,
                DocPaciente: columns[2].value
            };
            resultados.push(hc);
        });

        request.on('requestCompleted', () => {
            console.log('Resultados de la consulta:');
            console.log(resultados);
            if (!res.headersSent) {
                res.json(resultados);  // Envía la respuesta solo si no se ha enviado antes
                // res.status(200).send("holas")
            }
        });

        request.on('error', (err) => {
            console.error('Error en la consulta:', err);
            if (!res.headersSent) {
                res.status(500).send('Error interno del servidor');
            }
        });

        connection.execSql(request);
    } catch (error) {
        console.error('Error en la conexión o en la ejecución de la consulta:', error);
        if (!res.headersSent) {
            res.status(500).send('Error interno del servidor');
        }
    }
});

router.get('/ConsultarExisten', async (req, res) => {

});

router.post('/RegistrarRipsAutomatico/:TipoRips/:DX/:Modalidad/:GrupoServicio/:Servicio', (req, res) => {




    const TipoRips = req.params.TipoRips;
    const DX = req.params.DX;
    const Modalidad = req.params.Modalidad;
    const GrupoServicio = req.params.GrupoServicio;
    const Servicio = req.params.Servicio;

    let Actoquirurgico;
    if (TipoRips == 'AC') {
        Actoquirurgico = 1;
    } else if (TipoRips == 'AP') {
        Actoquirurgico = 2;
    }

    // console.log(`IdEvaluacion ${IdEvaluacion}`);

    const requestInsert = new Request(
        `
    
INSERT INTO [dbo].[RipsCodigoDX]
            ([Diagnostico Rips]
            ,[Id Acto Quirúrgico]
            ,[Id Modalidad Atencion]
            ,[Id Grupo Servicios]
            ,[Id Servicios]
        VALUES
            (
            @Cie1,
            @Actoquirurgico,
            @ModalidadGrupoServicioTecSal,
            @GrupoServicios,
            @CodServicio 
            )
    ) 
    `, (err) => {
        if (err) {
            console.error('Error al insertar el Rips:', err.message);
            res.status(500).json({ error: 'Error al insertar el RIPS' });
        } else {
            console.log('Inserción ejecutada con éxito');
            res.json({ success: true, message: 'Rips insertado correctamente' });
        }
    });

    // Ajustar los parámetros según las columnas y datos que estás insertando
    requestInsert.addParameter('Actoquirurgico', TYPES.Int, Actoquirurgico); 
    requestInsert.addParameter('Cie1', TYPES.NVarChar, DX);
    requestInsert.addParameter('ModalidadGrupoServicioTecSal', TYPES.Int, Modalidad);
    requestInsert.addParameter('GrupoServicios', TYPES.Int, GrupoServicio);
    requestInsert.addParameter('CodServicio', TYPES.Int, Servicio); 




    connection.execSql(requestInsert);
});



module.exports = router;