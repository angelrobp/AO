cp1 = box length:5 width:5 height:5 pos:[-60,10,0] wireColor:red
cp2 = box length:5 width:5 height:5 pos:[-10,100,0] wireColor:red
cp3 = box length:5 width:5 height:5 pos:[-30, 40,0] wireColor:red
cp4 = box length:2 width:2 height:2 pos:cp1.pos wireColor:yellow
cp5 = box length:2 width:2 height:2 pos:cp2.pos wireColor:yellow
ball = sphere radius:8 wireColor:green pos: cp1.pos

fn interpolacionCuadratica Traveler CP1 CP2 CP3 CP4 CP5= 
(
	V1 = (CP2-CP1)
	V2 = (CP3-CP2)
	
	inicio = 50
	final = 100
	diferencia = final-inicio
	animate on
	(
		for t in inicio to final by 1 do
		(
			at time t
			(
				frame = t-inicio
				
				CP4.pos = CP1 + ((normalize V1)*(((length V1)/diferencia)*frame))
				CP5.pos = CP2 + ((normalize V2)*(((length V2)/diferencia)*frame))
				V3 = (CP5.pos - CP4.pos)
				Traveler.pos = CP4.pos + ((normalize V3)*(((length V3)/diferencia)*frame))
			)			
		)
	)
	
	Traveler.showTrajectory = on
)

interpolacionCuadratica ball cp1.pos cp2.pos cp3.pos cp4 cp5