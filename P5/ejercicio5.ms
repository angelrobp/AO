fn interpolacionLineal punto1 punto2 divisiones frame=
(
	V=(punto2-punto1)
	return(punto1 + ((normalize V)*(((length V)/divisiones)*frame)))
)

fn interpolacionCuadratica punto1 punto2 punto3 divisiones frame= 
(
	p1= interpolacionLineal punto1 punto2 divisiones frame
	p2= interpolacionLineal punto2 punto3 divisiones frame
	
	return (interpolacionLineal p1 p2 divisiones frame) 
)

fn interpolacionCubica punto1 punto2 punto3 punto4 divisiones frame=
(
	p1= interpolacionCuadratica punto1 punto2 punto3 divisiones frame
	p2= interpolacionCuadratica punto2 punto3 punto4 divisiones frame
	
	return (interpolacionLineal p1 p2 divisiones frame) 
)

fn SquashAndStretch Traveler inicio final duracion factorSquash factorStretch animacionInicial animacionFinal=
(
	if (animacionInicial) then 
	(
		animate on 
		(
			at time inicio-1
			(
				Traveler.scale = [1, 1, 1] --pos. original
			)
		)
	)
	if (animacionFinal==true) then 
	(
		animate on 
		(
			at time inicio
			(
				Traveler.scale = factorSquash --aplasta
			)
			at time (inicio+(duracion/2))
			(
				Traveler.scale = factorStretch --estira
			)
			at time (inicio+duracion-1)
			(
				Traveler.scale = [1, 1, 1] --pos. original
			)
		)
	) else 
	(
		animate on 
		(
			at time (inicio)
			(
				Traveler.scale = factorSquash --aplasta
			)
			at time (inicio + (duracion/8))
			(
				Traveler.scale = factorStretch --estira
			)
			at time (inicio + (duracion*4/8))
			(
				Traveler.scale = [1, 1, 1] --pos. original
			)
			at time (final)
			(
				Traveler.scale = factorStretch --estira
			)
			at time (final+1)
			(
				Traveler.scale = [1, 1, 1] --pos. original
			)
		)
	)
)

fn CálculoAlturaMaxima valor1 valor2=
(
	
	if valor1>valor2 then return valor1 else return valor2
)

fn generarSalto basesDeSalto Traveler inicio final factorSquash factorStretch trayectoria=
(	
	--Ajuste de intervalo del timeline
	framesInicial= 1 --Claves usadas para estado inical del objeto antes del primer salto
	framesFinal = 12 --Claves usadas para estado final del objeto después del último salto
	animationRange = interval inicio (((final-inicio+1)+((basesDeSalto.count-2)*(final-inicio+2))+inicio)+framesInicial+framesFinal-1)
	
	pasos = 1
	diferencia = final-inicio
	id_CajasReferencia = 0
	animacionInicial=true
	animacionFinal=false
	
	for iterator=1 to basesDeSalto.count-1 do
	(
		base1 = basesDeSalto[iterator]
		base2 = basesDeSalto[iterator+1]
		
		--Cálculo altura general para puntos intermedios en función de la distancia entre los puntos de control inicial y final
		cateto1=base2.pos.x-base1.pos.x
		cateto2=base2.pos.y-base1.pos.y
		factor_altura= (sqrt ((cateto1^2)+(cateto2^2)))*0.7
		
		--Cálculo mayor altura entre dos cajas
		altura1 = base1.pos.z+base1.height
		altura2 = base2.pos.z+base2.height
		alturaMaxima = CálculoAlturaMaxima altura1 altura2
		
		startPosition = [base1.pos.x,base1.pos.y,altura1]
		finishPosition = [base2.pos.x,base2.pos.y,altura2]
		
		-- Creación de puntos intermedios con id 'cajaReferencia*' para Cálculo de interpolacion
		nombre=id_CajasReferencia as string
		nombre="cajaReferencia"+nombre
		cp2 = box name:nombre length:2 width:2 height:1 pos:[base1.pos.x+((base2.pos.x-base1.pos.x)/3),base1.pos.y+((base2.pos.y-base1.pos.y)/3),alturaMaxima+factor_altura] wireColor:red
		nombre=(id_CajasReferencia+1) as string
		nombre="cajaReferencia"+nombre
		cp3 = box name:nombre length:2 width:2 height:1 pos:[base1.pos.x+((base2.pos.x-base1.pos.x)*2/3),base1.pos.y+((base2.pos.y-base1.pos.y)*2/3),alturaMaxima+factor_altura] wireColor:red
		id_CajasReferencia = id_CajasReferencia+2
		
		if animacionInicial then --Si es el primer salto
		(
			primerInicio=inicio+framesInicial
			primerFinal=final+framesInicial
			animate on
			(
				at time inicio
				(
					Traveler.pos=startPosition
				)
				for t in primerInicio to primerFinal by pasos do
				(
					at time t
					(
						--Cálculo de interpolación cubica para la pareja de puntos de control inicial  y sus respectivos puntos intermedios
						frame = t-primerInicio
						Traveler.pos = interpolacionCubica startPosition cp2.pos cp3.pos finishPosition diferencia frame
					)			
				)
				at time (primerFinal+1)
				(
					Traveler.pos=finishPosition
				)
			)
			--Cálculo de squash and stretch del salto en cuestión
			SquashAndStretch Traveler primerInicio primerFinal diferencia factorSquash factorStretch animacionInicial animacionFinal
			animacionInicial=false
		) else --Si es un salto no inicial
		(
			animate on
			(
				at time inicio
				(
					Traveler.pos=startPosition
				)
				for t in inicio to final by pasos do
				(
					at time t
					(
						--Cálculo de interpolación cubica para una pareja de puntos de control dada y sus respectivos puntos intermedios
						frame = t-inicio
						Traveler.pos = interpolacionCubica startPosition cp2.pos cp3.pos finishPosition diferencia frame
					)			
				)
				at time (final+1)
				(
					Traveler.pos=finishPosition
				)
			)
			--Cálculo de squash and stretch del salto en cuestión
			SquashAndStretch Traveler inicio final diferencia factorSquash factorStretch animacionInicial animacionFinal
		)		
		
		final_anterior=final+2
		final=final+(final-inicio)+2
		inicio=final_anterior
	)
	
	--Creación de animación final tras el último salto
	animacionFinal=true
	base2 = basesDeSalto[basesDeSalto.count]
	altura2 = base2.pos.z+base2.height
	finishPosition = [base2.pos.x,base2.pos.y,altura2]
	animate on
	(
		at time (inicio+(framesFinal/2))
		(
			Traveler.pos.z = Traveler.pos.z+10
		)		
		at time (inicio+framesFinal-1)
		(
			Traveler.pos=finishPosition
		)
	)
	SquashAndStretch Traveler inicio (inicio+framesFinal-1) framesFinal factorSquash factorStretch animacionInicial animacionFinal	
	
	--Mostrar u ocultar trayectoria y puntos intermedios
	Traveler.showTrajectory = trayectoria
	if trayectoria then unhide $cajaReferencia* else hide $cajaReferencia*
)
-- Interfaz rollout (ventana) con nombre "salto"
rollout Salto "Salto"
(
-- Etiqueta de actor
	label EActor "Actor:" 
-- Selector de actor
	pickbutton UI_SelectorActor "Selecciona Actor"
	
-- Selectores de valores con rango de 0 a 100 y valor por defecto 0
	spinner UI_IF "Comienzo" range:[0,1000,0] type:#Integer
	spinner UI_FF "Duracion" range:[5,100,20] type:#Integer
	spinner UI_SQUASH "Squash" range:[0,1,0] type:#Float
	spinner UI_STRETCH "Stretch" range:[0,1,0] type:#Float
	checkbox UI_TRAJECTORY "Show Trajectory" checked:true	
-- Boton
	button UI_CrearSalto "Crear"
	
-- Cuando hago click en el pickbutton de actor y selecciono un objeto, el objeto se convierte en Traveler
	on UI_SelectorActor picked obj do
	(
		global Traveler = obj
		UI_SelectorActor.text = obj.name
	)
	-- Cuando pulso el boton de crear compruebo si existe el Traveler y genero la interpolacion lineal de los puntos P1 y P2
	on UI_CrearSalto pressed do
	(
		--Eliminación de puntos intermedios para cálculo de interpolaciones ya existentes
		delete $cajaReferencia* 
		basesDeSalto = $Box* as array -- crear el array con todos los puntos de control
		
		-- Creación de factores de Squash and stretch en función de los parametros de interfaz
		proporcionEstirarParaSquash = 1+(0.5*UI_SQUASH.value) 
		proporcionAplastarParaSquash = 1-(0.5*UI_SQUASH.value)
		proporcionEstirarparaStretch = 1+(0.5*UI_STRETCH.value) 
		proporcionAplastarParaStretch = 1-(0.5*UI_STRETCH.value) 
		factorSquash = [proporcionEstirarParaSquash, proporcionEstirarParaSquash, proporcionAplastarParaSquash]  
		factorStretch = [proporcionAplastarParaStretch, proporcionAplastarParaStretch, proporcionEstirarparaStretch]
		if Traveler!= undefined and basesDeSalto.count > 1 do
		(
			deletekeys Traveler
			Traveler.dir = [0,0,1]
			generarSalto basesDeSalto Traveler UI_IF.value (UI_IF.value+UI_FF.value) factorSquash factorStretch UI_TRAJECTORY.state	  
		)
    )
)

createDialog Salto

		