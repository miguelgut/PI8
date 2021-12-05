-- -------------------- 1. Inicialização do script-----------------------
function sysCall_init()
    corout=coroutine.create(coroutineMain)
end

function sysCall_actuation()
    if coroutine.status(corout)~='dead' then
        local ok,errorMsg=coroutine.resume(corout)
        if errorMsg then
            error(debug.traceback(corout,errorMsg),2)
        end
    end
end

function __getObjectOrientation__(a,b)
    -- compatibility routine, wrong results could be returned in some situations, in CoppeliaSim <4.0.1
    if b==sim.handle_parent then
        b=sim.getObjectParent(a)
    end
    if (b~=-1) and (sim.getObjectType(b)==sim.object_joint_type) and (sim.getInt32Param(sim.intparam_program_version)>=40001) then
        a=a+sim.handleflag_reljointbaseframe
    end
    return sim.getObjectOrientation(a,b)
end


stopSim = false
startSimulation = true
ref = 0
Kp = 70
Ki = 1
Kd = 0
Kx = 0
xRef = 0
Imax = 99
tRight = 0

-- -------------------- 1. Fim da inicialização do script-----------------------  

-- -------------------- 2. Rotina inicial --------------------------------------
function coroutineMain()

    gyro = sim.getObjectHandle("accel")
    motor1 = sim.getObjectHandle("motor_1")
    motor2 = sim.getObjectHandle("motor_2")
    wheel1 = sim.getObjectHandle("wheel_1")
    wheel2 = sim.getObjectHandle("wheel_2")
    dummy = sim.getObjectHandle("Dummy")
    body = sim.getObjectHandle("body")
    
    
    mOr1 = sim.getObjectMatrix(motor1,dummy)
    mOr2 = sim.getObjectMatrix(motor2,dummy)
    wOr1 = sim.getObjectMatrix(wheel1,dummy)
    wOr2 = sim.getObjectMatrix(wheel2,dummy)
    bOr  = sim.getObjectMatrix(body,dummy)
    xRef = sim.getObjectPosition(gyro, -1)[1]
    

    
    simUI.create(
    '<ui enabled = "true" modal = "false" title= "Controls" resizable = "true" closeable = "true" >'..
    '<button enabled = "true" text= "Stop" on-click ="stopSimul"/>'..
    '<button enabled = "true" text= "reposition" on-click ="reposition"/>'..
    '<button enabled = "true" text= "Restart" on-click ="startSim"/>'..
    '<label text= "Kp"/>'..
    '<edit enabled = "true" value ="30" on-editing-finished ="pChange"/>'..
    '<label text= "Ki"/>'..
    '<edit enabled = "true" value ="1" on-editing-finished ="iChange"/>'..
    '<label text= "Kd"/>'..
    '<edit enabled = "true" value ="0" on-editing-finished ="dChange"/>'..
    '<label text= "Kx"/>'..
    '<edit enabled = "true" value ="0" on-editing-finished ="xChange"/>'..
    '<label text= "Imax"/>'..
    '<edit enabled = "true" value ="100" on-editing-finished ="ImaxChange"/>'..
    '<label text= "Turn-Right slider"/>'..
    '<hslider enabled = "true" minimum = "0" maximum = "50" tick-interval = "1" tick-position = "left" on-change ="turnItRight"/>'..
    '</ui>'
    )
    
    while(true) do
        if startSimulation then
            startSimulation = false
            drive()
        end
    end
    

end
-- -------------------- 2. Fim da rotina inicial --------------------------------------

-- -------------------- 3. Finalização do script --------------------------------------
function stopSimul()
    print("################################ Stopping ######################################")
    print("sin(pi)"..math.sin(math.pi))
    sim.setJointTargetVelocity(motor1,0)
    sim.setJointTargetVelocity(motor2,0)
    stopSim = true
end
-- -------------------- 3. Fim da finalização do script --------------------------------------

-- -------------------- 4. Reposicionamento do corpo -----------------------------------------
function reposition()
    
    sim.setObjectMatrix(body,dummy,bOr)
    sim.setObjectMatrix(motor1,dummy,mOr1)
    sim.setObjectMatrix(motor2,dummy,mOr2)
    sim.setObjectMatrix(wheel1,dummy,wOr1)
    sim.setObjectMatrix(wheel2,dummy,wOr2)
    sim.setObjectOrientation(dummy,-1,{0,0,0})
    
end
-- -------------------- 4. Fim do reposicionamento do corpo ------------------------------------

-- -------------------- 5. Inicializando a simulação -------------------------------------------
function startSim()
    print("################################ Starting ######################################")
    P = 0
    I = 0
    D = 0
    err = 0
    pErr = 0
    c = 0
    ref = 0
    if startSimulation == false and stopSim == true then
        drive()
    end
    startSimulation = true
    stopSim = false
end
-- -------------------- 5. Fim da inicializando a simulação -------------------------------------------


-- -------------------- 6. Definindo os coeficientes K, Imax e tRight ---------------------------------

function pChange(uiHandle, id, newValue)
Kp = newValue*1
print(".Kp is set to: "..Kp)
end

function iChange(uiHandle, id, newValue)
Ki = newValue*1
print("..Ki is set to: "..Ki)
end

function xChange(uiHandle, id, newValue)
Kx = newValue*1
print("..Kx is set to: "..Kx)
end

function dChange(uiHandle, id, newValue)
Kd = newValue*1
print("...Kd is set to: "..Kd)
end

function ImaxChange(uiHandle, id, newValue)
Imax = newValue*1
print("...Imax is set to: "..Imax)
end

function turnItRight(uiHandle, id, newValue)
tRight = newValue*0.1
print("...tRight is set to: "..tRight)
end

-- ------------------- 6. Fim definição dos coeficientes K, Imax e tRight ---------------------------

-- ------------------- 7. Controle do corpot ---------------------------
function drive()

    reposition()
    maxVel = 20*math.pi
    
    integrate = true
    I = 0
    -- Erro anterior para ser utilizado na derivativa (d = pErr - err)
    pErr = (ref) - sim.getEulerAnglesFromMatrix(sim.getObjectMatrix(gyro,-1))[2]
    
    while stopSim == false do
       -- yaw em relação ao chão
       local yaw = sim.getEulerAnglesFromMatrix(sim.getObjectMatrix(gyro,-1))[3]
       -- corrige yaw do dummy
       sim.setObjectOrientation(dummy,-1,{0,0,yaw})
       -- Obtem demais angulos
       local pitch = sim.getEulerAnglesFromMatrix(sim.getObjectMatrix(gyro,dummy))[1]
       local roll = sim.getEulerAnglesFromMatrix(sim.getObjectMatrix(gyro,dummy))[2]
       local xErr = xRef - sim.getObjectPosition(gyro, -1)[1]
       
       -- Acoplando roll e pitch com angulo yaw
       --roll = roll - pitch * math.sin(yaw)
       --pitch = pitch + roll * math.sin(yaw)
       
       err = (ref + xErr) - roll
            
        --Derivativo
        D = Kd*(pErr - err)
        pErr = err
        
        --Integral
        I = I +  Ki* err
        
        --Proporcional
        P = Kp * err
        
        pid = P + I + D
        
        
        ------ Integral Windup -----
        if(math.abs(I) > Imax) then 
            I = Imax * I/math.abs(I)
        end
        

        -- Caso esteja habilitado o controle tRight, muda a velocidade da junta
        sim.setJointTargetVelocity(motor1,pid + tRight)
        sim.setJointTargetVelocity(motor2,pid - tRight)
        
    end 

end