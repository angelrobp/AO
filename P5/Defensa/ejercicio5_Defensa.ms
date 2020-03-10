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

fn calculoAlturaMaxima valor1 valor2=
(
	
	if valor1>valor2 then return valor1 else return valor2
)

fn generarSalto basesDeSalto Traveler inicio final factorSquash factorStretch trayectoria=
(	
	framesInicial= 1
	framesFinal = 12
	animationRange = interval inicio (((final-inicio+1)+((basesDeSalto.count-2)*(final-inicio+2))+inicio)+framesInicial+framesFinal-1) --Cambia el rango de frames desde el inicio deseado hasta la duración por el número de saltos

	--print ("final="+ ((basesDeSalto.count-1)*(final-inicio)) as string)
	--factor_altura=200
	
	pasos = 1
	diferencia = final-inicio
	id_CajasReferencia = 0
	animacionInicial=true
	animacionFinal=false
	
	for iterator=1 to basesDeSalto.count-1 do
	(
		base1 = basesDeSalto[iterator]
		base2 = basesDeSalto[iterator+1]
		
		cateto1=base2.pos.x-base1.pos.x
		cateto2=base2.pos.y-base1.pos.y
		factor_altura= (sqrt ((cateto1^2)+(cateto2^2)))*0.7
		
		altura1 = base1.pos.z+base1.height
		altura2 = base2.pos.z+base2.height
		alturaMaxima = calculoAlturaMaxima altura1 altura2
		
		startPosition = [base1.pos.x,base1.pos.y,altura1]
		finishPosition = [base2.pos.x,base2.pos.y,altura2]
		
		--variacion_altura=((base2.pos.x-base1.pos.x)*5)+((base2.pos.x-base1.pos.x)*5)
		
		nombre=id_CajasReferencia as string
		nombre="cajaReferencia"+nombre
		--cp2 = box name:nombre length:5 width:5 height:1 pos:[base1.pos.x+((base2.pos.x-base1.pos.x)*4/6),base1.pos.y+((base2.pos.y-base1.pos.y)*4/6),(base1.pos.z+(base2.pos.z-base1.pos.z))+100] wireColor:red
		cp2 = box name:nombre length:5 width:5 height:1 pos:[base1.pos.x+((base2.pos.x-base1.pos.x)/3),base1.pos.y+((base2.pos.y-base1.pos.y)/3),-(alturaMaxima+factor_altura)] wireColor:red
		nombre=(id_CajasReferencia+1) as string
		nombre="cajaReferencia"+nombre
		--cp3 = box name:nombre length:5 width:5 height:5 pos:[base1.pos.x+((base2.pos.x-base1.pos.x)*5/6),base1.pos.y+((base2.pos.y-base1.pos.y)*5/6),(base1.pos.z+(base2.pos.z-base1.pos.z))+100] wireColor:red
		cp3 = box name:nombre length:5 width:5 height:5 pos:[base1.pos.x+((base2.pos.x-base1.pos.x)*2/3),base1.pos.y+((base2.pos.y-base1.pos.y)*2/3),-(alturaMaxima+factor_altura)] wireColor:red
		id_CajasReferencia = id_CajasReferencia+2
		
		if animacionInicial then
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
						frame = t-primerInicio
						Traveler.pos = interpolacionCubica startPosition cp2.pos cp3.pos finishPosition diferencia frame
					)			
				)
				at time (primerFinal+1)
				(
					Traveler.pos=finishPosition
				)
			)
			SquashAndStretch Traveler primerInicio primerFinal diferencia factorSquash factorStretch animacionInicial animacionFinal
			animacionInicial=false
		) else
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
						frame = t-inicio
						Traveler.pos = interpolacionCubica startPosition cp2.pos cp3.pos finishPosition diferencia frame
					)			
				)
				at time (final+1)
				(
					Traveler.pos=finishPosition
				)
			)
			SquashAndStretch Traveler inicio final diferencia factorSquash factorStretch animacionInicial animacionFinal
		)		
		
		final_anterior=final+2
		final=final+(final-inicio)+2
		inicio=final_anterior
	)
	
	animacionFinal=true
	base2 = basesDeSalto[basesDeSalto.count]
	altura2 = base2.pos.z+base2.height
	finishPosition = [base2.pos.x,base2.pos.y,altura2]
	animate on
	(
		at time (inicio+(framesFinal/2))
		(
			Traveler.pos.z = Traveler.pos.z+10
			--Traveler.pos=finishPosition
		)		
		at time (inicio+framesFinal-1)
		(
			--Traveler.pos=finishPosition
			Traveler.pos=finishPosition
		)
	)
	SquashAndStretch Traveler inicio (inicio+framesFinal-1) framesFinal factorSquash factorStretch animacionInicial animacionFinal	
	
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
		delete $cajaReferencia* 
		basesDeSalto = $Box* as array -- crear el array con todos los puntos de control
		
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
			--Lineal Traveler P1.pos  P2.pos UI_IF.value (UI_IF.value+UI_FF.value)  
			--Traveler.showtrajectory = on
		)
    )
)

createDialog Salto

		