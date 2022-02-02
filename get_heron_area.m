function area = get_heron_area(a, b, c)
    x = norm(b - a);
    y = norm(c - a);
    z = norm(c - b);
    s = (x + y + z) * 0.5;

    area = power((s * (s - x) * (s - y) * (s - z)), 0.5);
end