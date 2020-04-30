def create(model, number_of_teeth, tooth_width, gear_height, internal_diameter, external_diameter, bore_diameter)
  group = model.active_entities.add_group
  
  num_segments = number_of_teeth
  bore_radius = bore_diameter / 2
  internal_radius = internal_diameter / 2
  external_radius = external_diameter / 2
  
  base_a_x = internal_radius
  base_a_y = 0
  base_b_x = external_radius
  base_b_y = 0

  x1, y1 = base_a_x, base_a_y + tooth_width
  x2, y2 = base_a_x, base_a_y - tooth_width
  x3, y3 = base_b_x, base_b_y - tooth_width
  x4, y4 = base_b_x, base_b_y + tooth_width

  angle_increase = 360 / number_of_teeth
  starting_angle = 0
  angle = starting_angle
  
  all_points = []
  while angle < 360 + starting_angle do
    angle_rad = angle * Math::PI / 180 
    projected_base_a_x, projected_base_a_y = base_a_x * Math.cos(angle_rad), base_a_x * Math.sin(angle_rad)
    projected_base_b_x, projected_base_b_y = base_b_x * Math.cos(angle_rad), base_b_x * Math.sin(angle_rad)
    projected_base_width_x, projected_base_width_y = tooth_width * Math.sin(angle_rad), tooth_width * Math.cos(angle_rad)

    x1, y1 = projected_base_a_x + projected_base_width_x, projected_base_a_y - projected_base_width_y
    x2, y2 = projected_base_b_x + projected_base_width_x, projected_base_b_y - projected_base_width_y
    x3, y3 = projected_base_b_x - projected_base_width_x, projected_base_b_y + projected_base_width_y
    x4, y4 = projected_base_a_x - projected_base_width_x, projected_base_a_y + projected_base_width_y

    points = [
      Geom::Point3d.new(x1.mm, y1.mm, 0),
      Geom::Point3d.new(x2.mm, y2.mm, 0),
      Geom::Point3d.new(x3.mm, y3.mm, 0),
      Geom::Point3d.new(x4.mm, y4.mm, 0),
    ]
    all_points = all_points + points
    
    angle = angle + angle_increase
  end
  
  bore_circle = group.entities.add_circle(ORIGIN, Z_AXIS, bore_radius.mm, 64)
  bore_face = group.entities.add_face(bore_circle)
  
  gear_face = group.entities.add_face(all_points)
  gear_face.reverse!
  
  group.entities.erase_entities(bore_face)
  
  gear_face.pushpull(gear_height.mm)

  group.explode
  model.commit_operation
end

model = Sketchup.active_model
sel = model.selection
ents = model.active_entities

number_of_teeth = 10
tooth_width = 0.5
gear_height = 1
internal_diameter = 6
external_diameter = 8
bore_diameter = 2

create(model, number_of_teeth, tooth_width, gear_height, internal_diameter, external_diameter, bore_diameter)
