function showImageOnAxes(ax, I, plotTitle)
%SHOWIMAGEONAXES Affiche une image sur un UIAxes.
    Idisp = I;
    if islogical(Idisp)
        Idisp = uint8(Idisp) * 255;
    end
    image(ax, Idisp);
    axis(ax, 'image');
    ax.XTick = [];
    ax.YTick = [];
    title(ax, plotTitle);
end
