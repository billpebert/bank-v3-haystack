<?php

/** @var \Illuminate\Database\Eloquent\Factory $factory */

use App\Model\Cashbook1;
use App\Model\Accounts;
use App\Model\Segments;
use Faker\Generator as Faker;

$factory->define(Cashbook1::class, function (Faker $faker)  use ($factory) {
    return [
        'Amount' => $faker->randomFloat($nbMaxDecimals = NULL, $min = 0, $max = NULL),
        'creditFK' => $factory->create(Accounts::class)->id,
        'DebitFK' => $factory->create(Accounts::class)->id,
        'Numbercredited' => $faker->randomFloat($nbMaxDecimals = NULL, $min = 0, $max = NULL),
        'Numberdebited' => $faker->randomFloat($nbMaxDecimals = NULL, $min = 0, $max = NULL),
        'tstamp' => $faker->dateTime($max = 'now', $timezone = null) ,
        'fx' => $faker->randomDigit,
        'Date' => $faker->dateTime($max = 'now', $timezone = null),

    ];
});
