<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Providers\RouteServiceProvider;
use Exception;
use Illuminate\Foundation\Auth\AuthenticatesUsers;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class LoginController extends Controller
{
    /*
    |--------------------------------------------------------------------------
    | Login Controller
    |--------------------------------------------------------------------------
    |
    | This controller handles authenticating users for the application and
    | redirecting them to your home screen. The controller uses a trait
    | to conveniently provide its functionality to your applications.
    |
    */

    use AuthenticatesUsers;

    /**
     * Where to redirect users after login.
     *
     * @var string
     */
    protected $redirectTo = RouteServiceProvider::HOME;
    
    /**
     * Create a new controller instance.
     *
     * @return void
     */
    // public function __construct()
    // {
    //     $this->middleware('guest')->except('logout');
    // }

    // public function __construct()
    // {
    //     $this->middleware('auth:sanctum'); // Protecting routes with Sanctum middleware
    // }

    protected function loginApi(Request $request)
    {
        $loginData = $request->validate([
            'username' => 'required',
            'password' => 'required'
        ]); 

        if (Auth::attempt($loginData)) {
            $token = Auth::user()->createToken('authToken')->plainTextToken;
            return response()->json([
                'message' => 'Login Success',
                'data' => Auth::user(),
                'token' => $token,
            ], 200);
        }
        return response()->json([
            'message' => 'Failed Login',
        ], 401);
    }

    private $response = [
        'success' => 0,
        'message' => null,
        'data' => null,
    ];

    public function index()
    {
        $user = Auth::user();
        $this->response['success'] = 1;
        $this->response['message'] = 'success';
        $this->response['data'] = $user;
        return response()->json($this->response, 200);
    }

    use AuthenticatesUsers;

    public function logoutApi(Request $request)
    {
        $user = $request->user();
        $user->tokens()->where('id', $user->currentAccessToken()->id)->delete();

        return response()->json([
            'message' => 'Logged out successfully',
        ], 200);
    }
   

}
