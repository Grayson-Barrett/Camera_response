function [XYZ] = ref2XYZ(refs,cmfs,illum)
    k = 100/sum(cmfs(:,2).*illum);
    X = k*sum(cmfs(:,1).*refs.*illum);
    Y = k*sum(cmfs(:,2).*refs.*illum);
    Z = k*sum(cmfs(:,3).*refs.*illum);
    XYZ = [X;Y;Z];
end
