<?php
/**
 * Skips the ps_guest row for crawlers (see override/classes/Connection.php).
 * Bots never keep the cookie, so every request used to create a new guest.
 * The cookie keeps id_guest unset, which carts already accept (id_guest 0).
 */
class Guest extends GuestCore
{
    public static function setNewGuest($cookie)
    {
        if (Connection::isUntrackedVisitor()) {
            return;
        }

        parent::setNewGuest($cookie);
    }
}
