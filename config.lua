--
-- For more information on config.lua see the Project Configuration Guide at:
-- https://docs.coronalabs.com/guide/basics/configSettings
--

application = {
    content = {
        width = 1920 / (2400 / 480), -- Maintain the aspect ratio but scale down for better performance
        height = 480,                -- Height will be consistent across devices
        scale = "letterbox",         -- Keep the aspect ratio
        fps = 60,
        
        imageSuffix = {
            ["@2x"] = 1.5,
            ["@3x"] = 2.5,
        },
    },
}