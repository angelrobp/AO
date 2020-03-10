Traveller = $Sphere001
AuxiliarBox = $Box001
Ground = $Plane001

fn createIntersectRay t AuxiliarBox Ground =
(
	--Creación de rayo en la posición de la caja auxiliar del frame actual y con dirección a Z negativo
	calculateRay = ray (at time t AuxiliarBox.pos) [0, 0, -1]

	--Calculo de intersección entre el rayo y el suelo
	return IntersectRay Ground calculateRay
)

fn generatePosition projectedPosition Traveller=
(
	--Calculo de posición del Traveller levantandolo por encima del suelo en la dirección de proyección (eje Z)
	return projectedPosition.pos + projectedPosition.dir * Traveller.radius
)

fn prueba Traveller AuxiliarBox Ground=
(
	
	deletekeys Traveller
	
	inicio=0
	final=200
	pasos=1
	
	animate on (
		for t in inicio to final by pasos do (
			
			projectedPosition = createIntersectRay t AuxiliarBox Ground
			
			newPosition = generatePosition projectedPosition Traveller
			
			at time t Traveller.pos = newPosition
				
			if t > inicio do (
				if t < final then (
					nextProjectedPosition = createIntersectRay (t+1) AuxiliarBox Ground
					nextPosition = generatePosition nextProjectedPosition Traveller
				) else (
					nextProjectedPosition = createIntersectRay inicio AuxiliarBox Ground
					nextPosition = generatePosition nextProjectedPosition Traveller
				)
				
				--Calculo vector definido por la posicion actual y la siguiente
				directionVector = nextPosition - newPosition	
				--Calculo vector de rotación (perpendicular al vector de dirección)
				rotationVector = cross directionVector projectedPosition.dir
				-- Calculo ángulo de rotación del objeto en funcion de la circunferencia de la pelota
				rotationAngle =  360 * length directionVector / (Traveller.radius * 2 * pi)
				
				-- Calculo de Quaternion con el angulo de rotacion y el vector de rotacion
					quaternion = quat rotationAngle (normalize rotationVector)
					
				-- Transformación del quaternion a una rotación de Euler para saber la rotación total en x, y, z 
				eulerRotation = QuatToEuler quaternion
				
				-- Roto el objeto 
				at  time t rotate Traveller eulerRotation
				
			
			)
		)
	)
)

prueba Traveller AuxiliarBox Ground