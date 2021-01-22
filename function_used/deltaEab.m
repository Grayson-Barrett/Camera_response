function [DEab] = deltaEab(Lab1,Lab2)
    DEab = sqrt(sum((Lab1-Lab2).^2,1));  
end