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

cp1 = box length:5 width:5 height:5 pos:[-60,10,0] wireColor:red
cp2 = box length:5 width:5 height:5 pos:[-10,100,0] wireColor:red
cp3 = box length:5 width:5 height:5 pos:[20,-80,0] wireColor:red
cp4 = box length:5 width:5 height:5 pos:[60,-10,0] wireColor:red

ball = sphere radius:8 wireColor:green pos: cp1.pos

inicio = 50
final = 100
pasos = 1
diferencia = final-inicio
animate on
(
	for t in inicio to final by pasos do
	(
		at time t
		(
			frame = t-inicio
			ball.pos = interpolacionCubica cp1.pos cp2.pos cp3.pos cp4.pos diferencia frame
		)			
	)
)
	
	ball.showTrajectory = on
		