-- =============================================
-- Script: Insert Event QR Type
-- Date: 2025-01-XX
-- Description: Inserts Event QR Type data into QRType table
-- =============================================

-- Insert Event QR Type
IF NOT EXISTS (SELECT 1 FROM [dbo].[QRType] WHERE QRTypeID = 'QRTYPE005')
BEGIN
    INSERT INTO [dbo].[QRType] (
        [QRTypeID],
        [TypeName],
        [DisplayName],
        [Description],
        [ButtonText],
        [ButtonLink],
        [IconURL],
        [Color],
        [DisplayOrder],
        [Active],
        [CreatedBy],
        [CreatedOn],
        [ModifiedBy],
        [ModifiedOn],
        [LastAction]
    )
    VALUES (
        'QRTYPE005',
        'event',
        'Event QR',
        'Create event QR codes with registration functionality. Perfect for conferences, workshops, networking events, and more.',
        'Create Event',
        '/qr-codes/type/event',
        'assets/icons/event-qr.svg',
        '#9B59B6',
        5,
        1,
        'SYSTEM',
        GETDATE(),
        'SYSTEM',
        GETDATE(),
        'INSERT'
    );
    PRINT 'QRType QRTYPE005 (Event QR) inserted successfully.';
END
ELSE
BEGIN
    PRINT 'QRType QRTYPE005 (Event QR) already exists.';
END
GO

-- Verify the inserted data
PRINT '';
PRINT '========================================';
PRINT 'Verification: Event QR Type';
PRINT '========================================';
SELECT 
    QRTypeID,
    TypeName,
    DisplayName,
    Description,
    Color,
    DisplayOrder,
    Active,
    ButtonText,
    ButtonLink,
    IconURL
FROM [dbo].[QRType]
WHERE QRTypeID = 'QRTYPE005';
GO

-- Show all QR Types ordered by DisplayOrder
PRINT '';
PRINT '========================================';
PRINT 'All QR Types (Ordered by DisplayOrder)';
PRINT '========================================';
SELECT 
    QRTypeID,
    TypeName,
    DisplayName,
    Color,
    DisplayOrder,
    Active
FROM [dbo].[QRType]
ORDER BY DisplayOrder;
GO

PRINT '';
PRINT 'Script execution completed successfully!';
GO
