<?php

/** @var \Illuminate\Database\Eloquent\Factory $factory */

use App\Model\Accounts;
use App\Model\Accounttypes;
use Faker\Generator as Faker;

$factory->define(Accounts::class, function (Faker $faker) use ($factory) {
    return [
        'AccountName' => $faker->unique()->name,
        'AccountFK' => $factory->create(Accounttypes::class)->id,
    ];
});
