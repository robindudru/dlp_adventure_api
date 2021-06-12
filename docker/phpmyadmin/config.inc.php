<?php

$sessionLifetime = 60 * 60 * 24;

$cfg['LoginCookieValidity'] = $sessionLifetime;

ini_set('session.gc_maxlifetime', $sessionLifetime);
