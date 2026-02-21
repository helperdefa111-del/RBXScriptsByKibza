local Lighting = game:GetService("Lighting")

-- Функція для встановлення "денного" освітлення
local function makeItBright()
    Lighting.Brightness = 2
    Lighting.ClockTime = 14
    Lighting.FogEnd = 100000
    Lighting.GlobalShadows = false
    Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
end

-- Викликаємо функцію одразу
makeItBright()

-- Додаємо цикл, щоб гра не могла змінити налаштування назад (наприклад, зміна дня/ночі)
Lighting.Changed:Connect(function()
    makeItBright()
end)

print("FullBright активовано!")
