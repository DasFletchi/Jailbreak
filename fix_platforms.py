import glob
import re

files = glob.glob("scenes/*block*.tscn")
for file in files:
    with open(file, 'r') as f:
        content = f.read()
    
    if "BoxShape3D_platform" in content:
        continue # Already processed
    
    # Add BoxShape3D at the end of sub_resources (before the first [node name=])
    # Let's just insert it right after the ext_resource
    content = re.sub(
        r'(\[ext_resource.*?\]\n)',
        r'\1\n[sub_resource type="BoxShape3D" id="BoxShape3D_platform"]\n\n',
        content,
        count=1
    )
    
    # Replace CSGBox3D tracks with AnimatableBody3D tracks
    content = content.replace('NodePath("CSGBox3D:rotation")', 'NodePath("AnimatableBody3D:rotation")')
    content = content.replace('NodePath("CSGBox3D:position")', 'NodePath("AnimatableBody3D:position")')
    
    # Replace the CSGBox3D node declaration
    # We want to replace:
    # [node name="CSGBox3D" type="CSGBox3D" parent="." unique_id=569271759]
    # use_collision = true
    #
    # With:
    # [node name="AnimatableBody3D" type="AnimatableBody3D" parent="."]
    #
    # [node name="CollisionShape3D" type="CollisionShape3D" parent="AnimatableBody3D"]
    # shape = SubResource("BoxShape3D_platform")
    #
    # [node name="CSGBox3D" type="CSGBox3D" parent="AnimatableBody3D" unique_id=569271759]
    
    pattern = r'\[node name="CSGBox3D" type="CSGBox3D" parent="\."(.*?)\]\nuse_collision = true'
    replacement = r'[node name="AnimatableBody3D" type="AnimatableBody3D" parent="."]\n\n[node name="CollisionShape3D" type="CollisionShape3D" parent="AnimatableBody3D"]\nshape = SubResource("BoxShape3D_platform")\n\n[node name="CSGBox3D" type="CSGBox3D" parent="AnimatableBody3D"\1]'
    
    content = re.sub(pattern, replacement, content)
    
    with open(file, 'w') as f:
        f.write(content)
    print(f"Fixed {file}")

