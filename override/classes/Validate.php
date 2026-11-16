<?php
/**
 * Format checks for the Slovak company IDs on addresses, used as form constraints by
 * override/classes/form/CustomerAddressFormatter.php. Values must be stored clean (the theme strips
 * spaces and uppercases as the customer types); empty passes because the fields are optional.
 */
class Validate extends ValidateCore
{
    /** IČO: 8 digits */
    public static function isSkIco($value)
    {
        return empty($value) || (bool) preg_match('/^\d{8}$/', (string) $value);
    }

    /** DIČ: 10 digits */
    public static function isSkDic($value)
    {
        return empty($value) || (bool) preg_match('/^\d{10}$/', (string) $value);
    }

    /** IČ DPH: SK followed by 10 digits */
    public static function isSkVatNumber($value)
    {
        return empty($value) || (bool) preg_match('/^SK\d{10}$/', (string) $value);
    }
}
